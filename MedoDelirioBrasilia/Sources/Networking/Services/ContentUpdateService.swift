//
//  ContentUpdateService.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 03/05/23.
//

import Foundation
import SwiftUI

protocol ContentUpdateServiceProtocol {

    var delegate: ContentUpdateServiceDelegate? { get set }

    func update() async
}

protocol ContentUpdateServiceDelegate: AnyObject {

    func set(totalUpdateCount: Int)
    func didProcessUpdate(number: Int)
    func update(status: ContentUpdateStatus, contentChanged: Bool)
}

/// A service that updates local content to stay in sync with their versions on the server.
class ContentUpdateService: ContentUpdateServiceProtocol {

    public weak var delegate: ContentUpdateServiceDelegate?

    // MARK: - Internal Properties

    private var firstRunUpdateHappened: Bool = false

    private var localUnsuccessfulUpdates: [UpdateEvent]?
    private var serverUpdates: [UpdateEvent]?

    // MARK: - Dependencies

    private let apiClient: APIClientProtocol
    private let localDatabase: LocalDatabaseProtocol
    private let logger: LoggerProtocol

    // MARK: - Initializer

    init(
        apiClient: APIClientProtocol,
        database: LocalDatabaseProtocol,
        logger: LoggerProtocol
    ) {
        self.apiClient = apiClient
        self.localDatabase = database
        self.logger = logger
    }
}

// MARK: - Public Functions

extension ContentUpdateService {

    /// Performs the content update operation with the server.
    public func update() async {
        await MainActor.run {
            delegate?.update(status: .updating, contentChanged: false)
        }

        defer {
            AppPersistentMemory().setLastUpdateAttempt(to: Date.now.iso8601withFractionalSeconds)
        }

        do {
            let didHaveAnyLocalUpdates = try await retryLocal()
            let didHaveAnyRemoteUpdates = try await syncDataWithServer()

            if didHaveAnyLocalUpdates || didHaveAnyRemoteUpdates {
                logger.logSyncSuccess(description: "Atualização concluída com sucesso.")
            } else {
                logger.logSyncSuccess(description: "Atualização concluída com sucesso, porém não existem novidades.")
            }

            await MainActor.run {
                delegate?.update(
                    status: .done,
                    contentChanged: didHaveAnyLocalUpdates || didHaveAnyRemoteUpdates
                )
            }
        } catch APIClientError.errorFetchingUpdateEvents(let errorMessage) {
            print(errorMessage)
            logger.logSyncError(description: errorMessage)
            delegate?.update(status: .updateError, contentChanged: false)
        } catch ContentUpdateError.errorInsertingUpdateEvent(let updateEventId) {
            logger.logSyncError(description: "Erro ao tentar inserir UpdateEvent no banco de dados.", updateEventId: updateEventId)
            delegate?.update(status: .updateError, contentChanged: false)
        } catch {
            logger.logSyncError(description: error.localizedDescription)
            delegate?.update(status: .updateError, contentChanged: false)
        }

        firstRunUpdateHappened = true
    }

    static func removeContentFile(
        named filename: String,
        atFolder contentFolderName: String
    ) throws {
        let documentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileManager = FileManager.default
        let file = documentsFolder.appendingPathComponent("\(contentFolderName)\(filename).mp3")
        if fileManager.fileExists(atPath: file.path) {
            try fileManager.removeItem(at: file)
        }
    }

    static func downloadFile(
        at fileUrl: URL,
        to localFolderName: String,
        contentId: String
    ) async throws {
        try removeContentFile(named: contentId, atFolder: localFolderName)
        let downloadedFileUrl = try await APIClient.downloadFile(from: fileUrl, into: localFolderName)
        print("File downloaded successfully at: \(downloadedFileUrl)")
    }
}

// MARK: - Internal Functions - Higher Level

extension ContentUpdateService {

    private func getUpdates(from updateDateToConsider: String) async throws -> [UpdateEvent] {
        print(updateDateToConsider)
        return try await apiClient.fetchUpdateEvents(from: updateDateToConsider)
    }

    private func retryLocal() async throws -> Bool {
        let localResult = try await retrieveUnsuccessfulLocalUpdates()
        print("Resultado do fetchLocalUnsuccessfulUpdates: \(localResult)")
        if localResult > 0 {
            try await syncUnsuccessful()
        }
        return localResult > 0
    }

    private func syncDataWithServer() async throws -> Bool {
        let result = try await retrieveServerUpdates()
        print("Resultado do retrieveServerUpdates: \(result)")
        if result > 0 {
            try await serverSync()
        }
        return result > 0
    }

    private func retrieveServerUpdates() async throws -> Double {
        print("retrieveServerUpdates()")
        let lastUpdateDate = localDatabase.dateTimeOfLastUpdate()
        print("lastUpdateDate: \(lastUpdateDate)")
        serverUpdates = try await getUpdates(from: lastUpdateDate)
        if var serverUpdates = serverUpdates {
            for i in serverUpdates.indices {
                do {
                    if try !localDatabase.exists(withId: serverUpdates[i].id) {
                        serverUpdates[i].didSucceed = false
                        try localDatabase.insert(updateEvent: serverUpdates[i])
                    }
                } catch {
                    throw ContentUpdateError.errorInsertingUpdateEvent(updateEventId: serverUpdates[i].id.uuidString)
                }
            }
        }
        return Double(serverUpdates?.count ?? 0)
    }

    private func retrieveUnsuccessfulLocalUpdates() async throws -> Double {
        print("fetchLocalUnsuccessfulUpdates()")
        localUnsuccessfulUpdates = try localDatabase.unsuccessfulUpdates()
        return Double(localUnsuccessfulUpdates?.count ?? 0)
    }

    private func serverSync() async throws {
        print("serverSync()")
        guard let serverUpdates = serverUpdates else { return }
        guard serverUpdates.isEmpty == false else {
            return print("NO UPDATES")
        }

        var updateNumber: Int = 0
        delegate?.set(totalUpdateCount: serverUpdates.count)

        for update in serverUpdates {
            await process(updateEvent: update)

            updateNumber += 1
            delegate?.didProcessUpdate(number: updateNumber)
        }
    }

    private func syncUnsuccessful() async throws {
        print("syncUnsuccessful()")
        guard let localUnsuccessfulUpdates = localUnsuccessfulUpdates else { return }
        guard localUnsuccessfulUpdates.isEmpty == false else {
            return print("NO LOCAL UNSUCCESSFUL UPDATES")
        }

        for update in localUnsuccessfulUpdates {
            await process(updateEvent: update)
        }
    }

    private func process(updateEvent: UpdateEvent) async {
        switch updateEvent.mediaType {
        case .sound:
            switch updateEvent.eventType {
            case .created:
                await createSound(from: updateEvent)

            case .metadataUpdated:
                await updateSoundMetadata(with: updateEvent)

            case .fileUpdated:
                await updateSoundFile(updateEvent)

            case .deleted:
                deleteSound(updateEvent)
            }

        case .author:
            switch updateEvent.eventType {
            case .created:
                await createAuthor(from: updateEvent)

            case .metadataUpdated:
                await updateAuthorMetadata(with: updateEvent)

            case .fileUpdated:
                Logger.shared.logSyncError(description: "Evento do tipo 'arquivo atualizado' recebido para o Autor(a) \"\(updateEvent.contentId)\", porém esse tipo de evento não é válido para Autores.", updateEventId: updateEvent.id.uuidString)

            case .deleted:
                await deleteAuthor(with: updateEvent)
            }

        case .song:
            switch updateEvent.eventType {
            case .created:
                await createSong(from: updateEvent)

            case .metadataUpdated:
                await updateSongMetadata(with: updateEvent)

            case .fileUpdated:
                await updateSongFile(updateEvent)

            case .deleted:
                deleteSong(updateEvent)
            }

        case .musicGenre:
            switch updateEvent.eventType {
            case .created:
                await createMusicGenre(from: updateEvent)

            case .metadataUpdated:
                await updateGenreMetadata(with: updateEvent)

            case .fileUpdated:
                Logger.shared.logSyncError(
                    description: "Evento do tipo 'arquivo atualizado' recebido para o Gênero Musical \"\(updateEvent.contentId)\", porém esse tipo de evento não é válido para Gêneros Musicais.",
                    updateEventId: updateEvent.id.uuidString
                )

            case .deleted:
                await deleteMusicGenre(with: updateEvent)
            }
        }
    }
}

// MARK: - Internal Functions - Lower Level

extension ContentUpdateService {

    func createSound(from updateEvent: UpdateEvent) async {
        let url = URL(string: APIClient.shared.serverPath + "v3/sound/\(updateEvent.contentId)")!
        do {
            let sound: Sound = try await APIClient.shared.get(from: url)
            try localDatabase.insert(sound: sound)

            try await ContentUpdateService.downloadFile(updateEvent.contentId)

            try localDatabase.markAsSucceeded(updateEventId: updateEvent.id)
            Logger.shared.logSyncSuccess(description: "Som \"\(sound.title)\" criado com sucesso.", updateEventId: updateEvent.id.uuidString)
        } catch {
            print(error)
            Logger.shared.logSyncError(description: error.localizedDescription, updateEventId: updateEvent.id.uuidString)
        }
    }

    func updateSoundMetadata(with updateEvent: UpdateEvent) async {
        let url = URL(string: APIClient.shared.serverPath + "v3/sound/\(updateEvent.contentId)")!
        do {
            let sound: Sound = try await APIClient.shared.get(from: url)
            try localDatabase.update(sound: sound)
            try localDatabase.markAsSucceeded(updateEventId: updateEvent.id)
            Logger.shared.logSyncSuccess(description: "Metadados do Som \"\(sound.title)\" atualizados com sucesso.", updateEventId: updateEvent.id.uuidString)
        } catch {
            print(error)
            Logger.shared.logSyncError(description: error.localizedDescription, updateEventId: updateEvent.id.uuidString)
        }
    }

    func updateSoundFile(_ updateEvent: UpdateEvent) async {
        do {
            try await ContentUpdateService.downloadFile(updateEvent.contentId)
            try localDatabase.setIsFromServer(to: true, onSoundId: updateEvent.contentId)
            try localDatabase.markAsSucceeded(updateEventId: updateEvent.id)
            Logger.shared.logSyncSuccess(description: "Arquivo do Som \"\(updateEvent.contentId)\" atualizado.", updateEventId: updateEvent.id.uuidString)
        } catch {
            print(error)
            Logger.shared.logSyncError(description: error.localizedDescription, updateEventId: updateEvent.id.uuidString)
        }
    }

    func deleteSound(_ updateEvent: UpdateEvent) {
        do {
            try localDatabase.delete(soundId: updateEvent.contentId)
            try ContentUpdateService.removeSoundFileIfExists(named: updateEvent.contentId)
            try localDatabase.markAsSucceeded(updateEventId: updateEvent.id)
            Logger.shared.logSyncSuccess(description: "Som \"\(updateEvent.contentId)\" apagado com sucesso.", updateEventId: updateEvent.id.uuidString)
        } catch {
            print(error)
            Logger.shared.logSyncError(description: error.localizedDescription, updateEventId: updateEvent.id.uuidString)
        }
    }

    // MARK: - Internal

    static func removeSoundFileIfExists(named filename: String) throws {
        let documentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileManager = FileManager.default
        let file = documentsFolder.appendingPathComponent("\(InternalFolderNames.downloadedSounds)\(filename).mp3")

        if fileManager.fileExists(atPath: file.path) {
            try fileManager.removeItem(at: file)
        }
    }

    static func downloadFile(_ contentId: String) async throws {
        let fileUrl = URL(string: APIConfig.baseServerURL + "sounds/\(contentId).mp3")!

        try removeSoundFileIfExists(named: contentId)

        let downloadedFileUrl = try await APIClient.downloadFile(from: fileUrl, into: InternalFolderNames.downloadedSounds)
        print("File downloaded successfully at: \(downloadedFileUrl)")
    }

    func createSong(from updateEvent: UpdateEvent) async {
        guard
            let contentUrl = URL(string: APIClient.shared.serverPath + "v3/song/\(updateEvent.contentId)"),
            let fileUrl = URL(string: APIConfig.baseServerURL + "songs/\(updateEvent.contentId).mp3")
        else { return }

        do {
            let song: Song = try await APIClient.shared.get(from: contentUrl)
            try localDatabase.insert(song: song)

            try await ContentUpdateService.downloadFile(
                at: fileUrl,
                to: InternalFolderNames.downloadedSongs,
                contentId: updateEvent.contentId
            )

            try localDatabase.markAsSucceeded(updateEventId: updateEvent.id)
            Logger.shared.logSyncSuccess(description: "Música \"\(song.title)\" criada com sucesso.", updateEventId: updateEvent.id.uuidString)
        } catch {
            Logger.shared.logSyncError(description: "Erro ao tentar criar Música: \(error.localizedDescription)", updateEventId: updateEvent.id.uuidString)
        }
    }

    func updateSongMetadata(with updateEvent: UpdateEvent) async {
        let url = URL(string: APIClient.shared.serverPath + "v3/song/\(updateEvent.contentId)")!
        do {
            let song: Song = try await APIClient.shared.get(from: url)
            try localDatabase.update(song: song)
            try localDatabase.markAsSucceeded(updateEventId: updateEvent.id)
            Logger.shared.logSyncSuccess(description: "Metadados da Música \"\(song.title)\" atualizados com sucesso.", updateEventId: updateEvent.id.uuidString)
        } catch {
            print(error)
            Logger.shared.logSyncError(description: error.localizedDescription, updateEventId: updateEvent.id.uuidString)
        }
    }

    func updateSongFile(_ updateEvent: UpdateEvent) async {
        guard let fileUrl = URL(string: APIConfig.baseServerURL + "songs/\(updateEvent.contentId).mp3") else { return }
        do {
            try await ContentUpdateService.downloadFile(
                at: fileUrl,
                to: InternalFolderNames.downloadedSongs,
                contentId: updateEvent.contentId
            )
            try localDatabase.setIsFromServer(to: true, onSongId: updateEvent.contentId)
            try localDatabase.markAsSucceeded(updateEventId: updateEvent.id)
            Logger.shared.logSyncSuccess(description: "Arquivo da Música \"\(updateEvent.contentId)\" atualizado.", updateEventId: updateEvent.id.uuidString)
        } catch {
            print(error)
            Logger.shared.logSyncError(description: error.localizedDescription, updateEventId: updateEvent.id.uuidString)
        }
    }

    func deleteSong(_ updateEvent: UpdateEvent) {
        do {
            try localDatabase.delete(songId: updateEvent.contentId)
            try ContentUpdateService.removeContentFile(
                named: updateEvent.contentId,
                atFolder: InternalFolderNames.downloadedSongs
            )
            try localDatabase.markAsSucceeded(updateEventId: updateEvent.id)
            Logger.shared.logSyncSuccess(description: "Som \"\(updateEvent.contentId)\" apagado com sucesso.", updateEventId: updateEvent.id.uuidString)
        } catch {
            print(error)
            Logger.shared.logSyncError(description: error.localizedDescription, updateEventId: updateEvent.id.uuidString)
        }
    }

    func createAuthor(from updateEvent: UpdateEvent) async {
        let url = URL(string: APIClient.shared.serverPath + "v3/author/\(updateEvent.contentId)")!
        do {
            let author: Author = try await APIClient.shared.get(from: url)

            try localDatabase.insert(author: author)

            try localDatabase.markAsSucceeded(updateEventId: updateEvent.id)
            Logger.shared.logSyncSuccess(description: "Autor(a) \"\(author.name)\" criado(a) com sucesso.", updateEventId: updateEvent.id.uuidString)
        } catch {
            print(error)
            Logger.shared.logSyncError(description: error.localizedDescription, updateEventId: updateEvent.id.uuidString)
        }
    }

    func updateAuthorMetadata(with updateEvent: UpdateEvent) async {
        let url = URL(string: APIClient.shared.serverPath + "v3/author/\(updateEvent.contentId)")!
        do {
            let author: Author = try await APIClient.shared.get(from: url)
            try localDatabase.update(author: author)
            try localDatabase.markAsSucceeded(updateEventId: updateEvent.id)
            Logger.shared.logSyncSuccess(description: "Metadados do(a) Autor(a) \"\(author.name)\" atualizados com sucesso.", updateEventId: updateEvent.id.uuidString)
        } catch {
            print(error)
            Logger.shared.logSyncError(description: error.localizedDescription, updateEventId: updateEvent.id.uuidString)
        }
    }

    func deleteAuthor(with updateEvent: UpdateEvent) async {
        do {
            try localDatabase.delete(authorId: updateEvent.contentId)
            try localDatabase.markAsSucceeded(updateEventId: updateEvent.id)
            Logger.shared.logSyncSuccess(description: "Autor(a) \"\(updateEvent.contentId)\" removido(a) com sucesso.", updateEventId: updateEvent.id.uuidString)
        } catch {
            print(error)
            Logger.shared.logSyncError(description: error.localizedDescription, updateEventId: updateEvent.id.uuidString)
        }
    }

    func createMusicGenre(from updateEvent: UpdateEvent) async {
        let url = URL(string: APIClient.shared.serverPath + "v3/music-genre/\(updateEvent.contentId)")!
        do {
            let genre: MusicGenre = try await APIClient.shared.get(from: url)

            try localDatabase.insert(genre: genre)

            try localDatabase.markAsSucceeded(updateEventId: updateEvent.id)
            Logger.shared.logSyncSuccess(description: "Gênero Musical \"\(genre.name)\" criado com sucesso.", updateEventId: updateEvent.id.uuidString)
        } catch {
            Logger.shared.logSyncError(description: error.localizedDescription, updateEventId: updateEvent.id.uuidString)
        }
    }

    func updateGenreMetadata(with updateEvent: UpdateEvent) async {
        let url = URL(string: APIClient.shared.serverPath + "v3/music-genre/\(updateEvent.contentId)")!
        do {
            let genre: MusicGenre = try await APIClient.shared.get(from: url)
            try localDatabase.update(genre: genre)
            try localDatabase.markAsSucceeded(updateEventId: updateEvent.id)
            Logger.shared.logSyncSuccess(description: "Metadados do Gênero Musical \"\(genre.name)\" atualizados com sucesso.", updateEventId: updateEvent.id.uuidString)
        } catch {
            Logger.shared.logSyncError(description: error.localizedDescription, updateEventId: updateEvent.id.uuidString)
        }
    }

    func deleteMusicGenre(with updateEvent: UpdateEvent) async {
        do {
            try localDatabase.delete(genreId: updateEvent.contentId)
            try localDatabase.markAsSucceeded(updateEventId: updateEvent.id)
            Logger.shared.logSyncSuccess(description: "Gênero Musical \"\(updateEvent.contentId)\" removido com sucesso.", updateEventId: updateEvent.id.uuidString)
        } catch {
            Logger.shared.logSyncError(description: error.localizedDescription, updateEventId: updateEvent.id.uuidString)
        }
    }
}
