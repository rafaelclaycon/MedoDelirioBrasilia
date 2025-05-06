//
//  SyncService.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 03/05/23.
//

import Foundation
import SwiftUI

internal protocol SyncServiceProtocol {

    func getUpdates(from updateDateToConsider: String) async throws -> [UpdateEvent]
    func process(updateEvent: UpdateEvent) async
}

class SyncService: SyncServiceProtocol {

    private let apiClient: APIClientProtocol
    let injectedDatabase: LocalDatabaseProtocol
    
    init(
        apiClient: APIClientProtocol,
        localDatabase: LocalDatabaseProtocol
    ) {
        self.apiClient = apiClient
        self.injectedDatabase = localDatabase
    }
    
    func getUpdates(from updateDateToConsider: String) async throws -> [UpdateEvent] {
        print(updateDateToConsider)
        return try await apiClient.fetchUpdateEvents(from: updateDateToConsider)
    }
    
    func process(updateEvent: UpdateEvent) async {
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
                Logger.shared.logSyncError(description: "Evento do tipo 'arquivo atualizado' recebido para o Gênero Musical \"\(updateEvent.contentId)\", porém esse tipo de evento não é válido para Gêneros Musicais.", updateEventId: updateEvent.id.uuidString)

            case .deleted:
                await deleteMusicGenre(with: updateEvent)
            }
            
        }
    }
}

extension SyncService {

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

enum SyncResult {
    case nothingToUpdate, updated
}

enum SyncError: Error {

    case errorInsertingUpdateEvent(updateEventId: String)
    case updateError
}

enum SyncUIStatus: CustomStringConvertible {

    case updating, done, updateError

    var description: String {
        switch self {
        case .updating:
            return "Atualizando..."
        case .done:
            return "Você tem as últimas novidades."
        case .updateError:
            return "Não foi possível obter as últimas novidades."
        }
    }
}
