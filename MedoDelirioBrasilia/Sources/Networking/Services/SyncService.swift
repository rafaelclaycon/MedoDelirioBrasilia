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
    
    @AppStorage("lastUpdateDate") private var lastUpdateDate = "all"
    
    init(
        connectionManager: ConnectionManagerProtocol,
        networkRabbit: NetworkRabbitProtocol,
        localDatabase: LocalDatabaseProtocol
    ) {
        self.connectionManager = connectionManager
        self.networkRabbit = networkRabbit
        self.localDatabase = localDatabase
    }
    
    func syncWithServer() async -> SyncResult {
        guard connectionManager.hasConnectivity() else {
            return .noInternet
        }
        
        do {
            print(lastUpdateDate)
            
            let updates = try await networkRabbit.fetchUpdateEvents(from: lastUpdateDate)
            
            guard !updates.isEmpty else { return .nothingToUpdate }
            
            for update in updates {
                print(update.id)
                await process(updateEvent: update)
            }
            
            return .updated
        } catch {
            print(error.localizedDescription)
            return .updateError
        }
    }
    
    private func process(updateEvent: UpdateEvent) async {
        switch updateEvent.mediaType {
        case .sound:
            switch updateEvent.eventType {
            case .created:
                let url = URL(string: networkRabbit.serverPath + "v3/sound/\(updateEvent.contentId)")!
                do {
                    var sound: Sound = try await NetworkRabbit.get(from: url)
                    try localDatabase.insert(sound: sound)
                } catch {
                    print(error.localizedDescription)
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
    
    case noInternet, nothingToUpdate, updateError, updated, unableToGetLastDate
}
