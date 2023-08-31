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
//        return [
//            UpdateEvent(id: UUID(), contentId: UUID().uuidString, dateTime: Date.now.iso8601withFractionalSeconds, mediaType: .song, eventType: .metadataUpdated),
//            UpdateEvent(id: UUID(), contentId: UUID().uuidString, dateTime: Date.now.iso8601withFractionalSeconds, mediaType: .song, eventType: .metadataUpdated),
//            UpdateEvent(id: UUID(), contentId: UUID().uuidString, dateTime: Date.now.iso8601withFractionalSeconds, mediaType: .song, eventType: .metadataUpdated),
//            UpdateEvent(id: UUID(), contentId: UUID().uuidString, dateTime: Date.now.iso8601withFractionalSeconds, mediaType: .song, eventType: .metadataUpdated),
//            UpdateEvent(id: UUID(), contentId: UUID().uuidString, dateTime: Date.now.iso8601withFractionalSeconds, mediaType: .song, eventType: .metadataUpdated)
//        ]
        
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
            Logger.shared.logSyncError(description: "Nada pôde ser feito com a Música \"\(updateEvent.contentId)\" pois a sincronização de Músicas ainda não existe.", updateEventId: updateEvent.id.uuidString)
            print("Not implemented yet")
        }
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

enum SyncUIStatus {
    case updating, done, noInternet, updateError
}
