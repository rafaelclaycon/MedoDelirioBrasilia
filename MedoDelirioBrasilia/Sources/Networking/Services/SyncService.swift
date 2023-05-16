//
//  SyncService.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 03/05/23.
//

import Foundation
import SwiftUI

class SyncService {
    
    private let connectionManager: ConnectionManagerProtocol
    private let networkRabbit: NetworkRabbitProtocol
    private let localDatabase: LocalDatabaseProtocol
    
    init(
        connectionManager: ConnectionManagerProtocol,
        networkRabbit: NetworkRabbitProtocol,
        localDatabase: LocalDatabaseProtocol
    ) {
        self.connectionManager = connectionManager
        self.networkRabbit = networkRabbit
        self.localDatabase = localDatabase
    }
    
    func getUpdates(from updateDateToConsider: String) async throws -> [UpdateEvent] {
        return [
            UpdateEvent(id: UUID(), contentId: UUID().uuidString, dateTime: Date.now.iso8601withFractionalSeconds, mediaType: .song, eventType: .metadataUpdated),
            UpdateEvent(id: UUID(), contentId: UUID().uuidString, dateTime: Date.now.iso8601withFractionalSeconds, mediaType: .song, eventType: .metadataUpdated),
            UpdateEvent(id: UUID(), contentId: UUID().uuidString, dateTime: Date.now.iso8601withFractionalSeconds, mediaType: .song, eventType: .metadataUpdated),
            UpdateEvent(id: UUID(), contentId: UUID().uuidString, dateTime: Date.now.iso8601withFractionalSeconds, mediaType: .song, eventType: .metadataUpdated),
            UpdateEvent(id: UUID(), contentId: UUID().uuidString, dateTime: Date.now.iso8601withFractionalSeconds, mediaType: .song, eventType: .metadataUpdated)
        ]
        
//        guard connectionManager.hasConnectivity() else {
//            throw SyncError.noInternet
//        }
//        print(updateDateToConsider)
//        return try await networkRabbit.fetchUpdateEvents(from: updateDateToConsider)
    }
    
    func hasConnectivity() -> Bool {
        return connectionManager.hasConnectivity()
    }
    
    func process(updateEvent: UpdateEvent) async {
        switch updateEvent.mediaType {
        case .sound:
            switch updateEvent.eventType {
            case .created:
                let url = URL(string: networkRabbit.serverPath + "v3/sound/\(updateEvent.contentId)")!
                do {
                    let sound: Sound = try await NetworkRabbit.get(from: url)
                    try localDatabase.insert(sound: sound)
                    
                    let fileUrl = URL(string: "http://170.187.141.103:8080/sounds/\(updateEvent.contentId).mp3")!
                    let downloadedFileUrl = try await NetworkRabbit.downloadFile(url: fileUrl)
                    print("File downloaded successfully at: \(downloadedFileUrl)")
                } catch {
                    print(error)
                    print(error.localizedDescription)
                }
                
            case .metadataUpdated:
                let url = URL(string: networkRabbit.serverPath + "v3/sound/\(updateEvent.contentId)")!
                do {
                    let sound: Sound = try await NetworkRabbit.get(from: url)
                    try localDatabase.update(sound: sound)
                } catch {
                    print(error)
                }
                
            default:
                print("Not implemented yet")
            }
            
        case .author:
            print("Not implemented yet")
            
        case .song:
            print("Not implemented yet")
        }
    }
}

enum SyncResult {
    
    case nothingToUpdate, updated
}

enum SyncError: Error {
    
    case noInternet, updateError
}
