//
//  SoundService.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 03/05/23.
//

import Foundation

class SoundService {
    
    private let connectionManager: ConnectionManagerProtocol
    private let networkRabbit: NetworkRabbitProtocol
    
    init(
        connectionManager: ConnectionManagerProtocol,
        networkRabbit: NetworkRabbitProtocol
    ) {
        self.connectionManager = connectionManager
        self.networkRabbit = networkRabbit
    }
    
    func syncWithServer() async -> SyncResult {
        guard connectionManager.hasConnectivity() else {
            return .noInternet
        }
        
        do {
            let updates = try await networkRabbit.fetchUpdateEvents()
            
            guard !updates.isEmpty else { return .nothingToUpdate }
            
            updates.forEach { update in
                print("TRANS LIB NOW: \(update.id)")
            }
            
            return .updated
        } catch {
            print(error.localizedDescription)
            return .updateError
        }
    }
}

enum SyncResult {
    
    case noInternet, nothingToUpdate, updateError, updated
}
