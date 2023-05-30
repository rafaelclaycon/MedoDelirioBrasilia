//
//  SyncService+Author.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 23/05/23.
//

import Foundation

extension SyncService {
    
    func createAuthor(from updateEvent: UpdateEvent) async {
        let url = URL(string: networkRabbit.serverPath + "v3/sound/\(updateEvent.contentId)")!
        do {
            let sound: Sound = try await NetworkRabbit.get(from: url)
            
            try injectedDatabase.insert(sound: sound)
            
            try injectedDatabase.markAsSucceeded(updateEventId: updateEvent.id)
        } catch {
            print(error)
            Logger.logSyncError(description: error.localizedDescription, updateEventId: updateEvent.id.uuidString)
        }
    }
    
    func updateAuthorMetadata(with updateEvent: UpdateEvent) {
        print("Not implemented yet")
    }
    
    func deleteAuthor(_ updateEvent: UpdateEvent) {
        print("Not implemented yet")
    }
}
