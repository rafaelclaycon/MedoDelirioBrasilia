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
    func hasConnectivity() -> Bool
    func process(updateEvent: UpdateEvent) async
}

class SyncService: SyncServiceProtocol {

    private let connectionManager: ConnectionManagerProtocol
    private let networkRabbit: NetworkRabbitProtocol
    let injectedDatabase: LocalDatabaseProtocol
    
    init(
        connectionManager: ConnectionManagerProtocol,
        networkRabbit: NetworkRabbitProtocol,
        localDatabase: LocalDatabaseProtocol
    ) {
        self.connectionManager = connectionManager
        self.networkRabbit = networkRabbit
        self.injectedDatabase = localDatabase
    }
    
    func getUpdates(from updateDateToConsider: String) async throws -> [UpdateEvent] {
        guard connectionManager.hasConnectivity() else {
            throw SyncError.noInternet
        }
        print(updateDateToConsider)
        return try await networkRabbit.fetchUpdateEvents(from: updateDateToConsider)
    }
    
    func hasConnectivity() -> Bool {
        return connectionManager.hasConnectivity()
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

    internal func removeContentFile(
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

    internal func downloadFile(
        at fileUrl: URL,
        to localFolderName: String,
        contentId: String
    ) async throws {
        try removeContentFile(named: contentId, atFolder: localFolderName)
        let downloadedFileUrl = try await NetworkRabbit.downloadFile(from: fileUrl, into: localFolderName)
        print("File downloaded successfully at: \(downloadedFileUrl)")
    }
}

enum SyncResult {
    case nothingToUpdate, updated
}

enum SyncError: Error {
    case noInternet
    case errorInsertingUpdateEvent(updateEventId: String)
    case updateError
}

enum SyncUIStatus: CustomStringConvertible {

    case updating, done, noInternet, updateError

    var description: String {
        switch self {
        case .updating:
            return "Atualizando..."
        case .done:
            return "Sincronização concluída com sucesso."
        case .noInternet:
            return "Não foi possível atualizar pois o aparelho está offline."
        case .updateError:
            return "Houve um problema com a sincronização."
        }
    }
}
