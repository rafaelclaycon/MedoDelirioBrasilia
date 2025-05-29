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
    private let fileManager: ContentFileManagerProtocol
    private let appMemory: AppPersistentMemoryProtocol
    private let logger: LoggerProtocol

    // MARK: - Initializer

    init(
        apiClient: APIClientProtocol,
        database: LocalDatabaseProtocol,
        fileManager: ContentFileManagerProtocol,
        appMemory: AppPersistentMemoryProtocol,
        logger: LoggerProtocol
    ) {
        self.apiClient = apiClient
        self.localDatabase = database
        self.fileManager = fileManager
        self.appMemory = appMemory
        self.logger = logger
    }
}

// MARK: - Public Functions

extension ContentUpdateService {

    /// Performs the content update operation with the server.
    public func update() async {
        guard appMemory.hasAllowedContentUpdate() else {
            await MainActor.run {
                delegate?.update(status: .pendingFirstUpdate, contentChanged: false)
            }
            return
        }

        await MainActor.run {
            delegate?.update(status: .updating, contentChanged: false)
        }

        defer {
            appMemory.setLastUpdateAttempt(to: Date.now.iso8601withFractionalSeconds)
        }

        do {
            let didHaveAnyLocalUpdates = try await retryLocal()
            let didHaveAnyRemoteUpdates = try await syncDataWithServer()

            if didHaveAnyLocalUpdates || didHaveAnyRemoteUpdates {
                logger.updateSuccess("Atualização concluída com sucesso.")
            } else {
                logger.updateSuccess("Atualização concluída com sucesso, porém não existem novidades.")
            }

            await MainActor.run {
                delegate?.update(
                    status: .done,
                    contentChanged: didHaveAnyLocalUpdates || didHaveAnyRemoteUpdates
                )
            }
        } catch APIClientError.errorFetchingUpdateEvents(let errorMessage) {
            print(errorMessage)
            logger.updateError(errorMessage)
            delegate?.update(status: .updateError, contentChanged: false)
        } catch ContentUpdateError.errorInsertingUpdateEvent(let updateEventId) {
            logger.updateError("Erro ao tentar inserir UpdateEvent no banco de dados.", updateEventId: updateEventId)
            delegate?.update(status: .updateError, contentChanged: false)
        } catch {
            logger.updateError(error.localizedDescription)
            delegate?.update(status: .updateError, contentChanged: false)
        }

        firstRunUpdateHappened = true
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
        switch updateEvent.eventType {
        case .created:
            await createResource(for: updateEvent)

        case .metadataUpdated:
            await updateResource(for: updateEvent)

        case .fileUpdated:
            if [MediaType.author, MediaType.musicGenre].contains(updateEvent.mediaType) {
                logger.updateError(
                    "Evento do tipo 'arquivo atualizado' recebido para o \(updateEvent.mediaType.description) \(updateEvent.contentId), porém esse tipo de evento não é válido para esse tipo de mídia.",
                    updateEventId: updateEvent.id.uuidString
                )
            } else {
                await updateResourceFile(for: updateEvent)
            }

        case .deleted:
            await deleteResource(for: updateEvent)
        }
    }
}

// MARK: - Internal Functions - Lower Level

extension ContentUpdateService {

    private func createResource(for updateEvent: UpdateEvent) async {
        do {
            guard try !resourceAlreadyExists(updateEvent) else {
                try localDatabase.markAsSucceeded(updateEventId: updateEvent.id)
                let message = "\(updateEvent.mediaType.description) - \(updateEvent.contentId) já existe, marcando evento como bem sucedido."
                logger.updateError(message, updateEventId: updateEvent.id.uuidString)
                return
            }

            switch updateEvent.mediaType {
            case .sound:
                try localDatabase.insert(sound: try await apiClient.sound(updateEvent.contentId))
                try await fileManager.downloadSound(withId: updateEvent.contentId)
            case .author:
                try localDatabase.insert(author: try await apiClient.author(updateEvent.contentId))
            case .song:
                try localDatabase.insert(song: try await apiClient.song(updateEvent.contentId))
                try await fileManager.downloadSong(withId: updateEvent.contentId)
            case .musicGenre:
                try localDatabase.insert(genre: try await apiClient.musicGenre(updateEvent.contentId))
            }

            try localDatabase.markAsSucceeded(updateEventId: updateEvent.id)
            logger.updateSuccess(
                "\(updateEvent.mediaType.description) \(updateEvent.contentId) criado com sucesso.",
                updateEventId: updateEvent.id.uuidString
            )
        } catch {
            let message = "Erro ao tentar criar \(updateEvent.mediaType.description) - \(updateEvent.contentId): \(error.localizedDescription)"
            print(message)
            logger.updateError(message, updateEventId: updateEvent.id.uuidString)
        }
    }

    private func resourceAlreadyExists(_ updateEvent: UpdateEvent) throws -> Bool {
        switch updateEvent.mediaType {
        case .sound, .song:
            return try localDatabase.contentExists(withId: updateEvent.contentId)
        case .author:
            return try localDatabase.author(withId: updateEvent.contentId) != nil
        case .musicGenre:
            return try localDatabase.musicGenre(withId: updateEvent.contentId) != nil
        }
    }

    private func updateResource(for updateEvent: UpdateEvent) async {

    }

    private func updateResourceFile(for updateEvent: UpdateEvent) async {
        guard [MediaType.sound, MediaType.song].contains(updateEvent.mediaType) else { return }
        do {
            if updateEvent.mediaType == .sound {
                try await fileManager.downloadSound(withId: updateEvent.contentId)
                try localDatabase.setIsFromServer(to: true, onSoundId: updateEvent.contentId)
            } else {
                try await fileManager.downloadSong(withId: updateEvent.contentId)
                try localDatabase.setIsFromServer(to: true, onSongId: updateEvent.contentId)
            }
            try localDatabase.markAsSucceeded(updateEventId: updateEvent.id)
            logger.updateSuccess("Arquivo do \(updateEvent.mediaType.description) \(updateEvent.contentId) atualizado.", updateEventId: updateEvent.id.uuidString)
        } catch {
            let message = "Erro ao tentar atualizar arquivo de \(updateEvent.mediaType.description) - \(updateEvent.contentId): \(error.localizedDescription)"
            print(message)
            logger.updateError(message, updateEventId: updateEvent.id.uuidString)
        }
    }

    private func deleteResource(for updateEvent: UpdateEvent) async {
        do {
            switch updateEvent.mediaType {
            case .sound:
                try localDatabase.delete(soundId: updateEvent.contentId)
                try fileManager.removeSoundFile(id: updateEvent.contentId)
            case .author:
                try localDatabase.delete(authorId: updateEvent.contentId)
            case .song:
                try localDatabase.delete(songId: updateEvent.contentId)
                try fileManager.removeSongFile(id: updateEvent.contentId)
            case .musicGenre:
                try localDatabase.delete(genreId: updateEvent.contentId)
            }

            try localDatabase.markAsSucceeded(updateEventId: updateEvent.id)
            logger.updateSuccess(
                "\(updateEvent.mediaType.description) \(updateEvent.contentId) removido com sucesso.",
                updateEventId: updateEvent.id.uuidString
            )
        } catch {
            let message = "Erro ao tentar remover \(updateEvent.mediaType.description) - \(updateEvent.contentId): \(error.localizedDescription)"
            print(message)
            logger.updateError(message, updateEventId: updateEvent.id.uuidString)
        }
    }

//    func updateSoundMetadata(with updateEvent: UpdateEvent) async {
//        let url = URL(string: apiClient.serverPath + "v3/sound/\(updateEvent.contentId)")!
//        do {
//            let sound: Sound = try await apiClient.get(from: url)
//            try localDatabase.update(sound: sound)
//            try localDatabase.markAsSucceeded(updateEventId: updateEvent.id)
//            logger.updateSuccess("Metadados do Som \"\(sound.title)\" atualizados com sucesso.", updateEventId: updateEvent.id.uuidString)
//        } catch {
//            print(error)
//            logger.updateError(error.localizedDescription, updateEventId: updateEvent.id.uuidString)
//        }
//    }
//
//    func updateSongMetadata(with updateEvent: UpdateEvent) async {
//        let url = URL(string: apiClient.serverPath + "v3/song/\(updateEvent.contentId)")!
//        do {
//            let song: Song = try await apiClient.get(from: url)
//            try localDatabase.update(song: song)
//            try localDatabase.markAsSucceeded(updateEventId: updateEvent.id)
//            logger.updateSuccess("Metadados da Música \"\(song.title)\" atualizados com sucesso.", updateEventId: updateEvent.id.uuidString)
//        } catch {
//            print(error)
//            logger.updateError(error.localizedDescription, updateEventId: updateEvent.id.uuidString)
//        }
//    }
//
//    func updateAuthorMetadata(with updateEvent: UpdateEvent) async {
//        let url = URL(string: apiClient.serverPath + "v3/author/\(updateEvent.contentId)")!
//        do {
//            let author: Author = try await apiClient.get(from: url)
//            try localDatabase.update(author: author)
//            try localDatabase.markAsSucceeded(updateEventId: updateEvent.id)
//            logger.updateSuccess("Metadados do(a) Autor(a) \"\(author.name)\" atualizados com sucesso.", updateEventId: updateEvent.id.uuidString)
//        } catch {
//            print(error)
//            logger.updateError(error.localizedDescription, updateEventId: updateEvent.id.uuidString)
//        }
//    }
//
//    func updateGenreMetadata(with updateEvent: UpdateEvent) async {
//        let url = URL(string: apiClient.serverPath + "v3/music-genre/\(updateEvent.contentId)")!
//        do {
//            let genre: MusicGenre = try await apiClient.get(from: url)
//            try localDatabase.update(genre: genre)
//            try localDatabase.markAsSucceeded(updateEventId: updateEvent.id)
//            logger.updateSuccess("Metadados do Gênero Musical \"\(genre.name)\" atualizados com sucesso.", updateEventId: updateEvent.id.uuidString)
//        } catch {
//            logger.updateError(error.localizedDescription, updateEventId: updateEvent.id.uuidString)
//        }
//    }
}
