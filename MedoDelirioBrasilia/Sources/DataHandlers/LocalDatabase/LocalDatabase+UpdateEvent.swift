//
//  LocalDatabase+UpdateEvent.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 24/05/23.
//

import Foundation
import SQLite

extension LocalDatabase {
    
    func insert(updateEvent newUpdateEvent: UpdateEvent) throws {
        let insert = try updateEventTable.insert(newUpdateEvent)
        try db.run(insert)
    }
    
    func markAsSucceeded(updateEventId: UUID) throws {
        let did_succeed_column = Expression<Bool>("didSucceed")
        let update_event_id_column = Expression<UUID>("id")
        
        let updateQuery = updateEventTable
            .filter(update_event_id_column == updateEventId)
            .update(did_succeed_column <- true)
        
        try db.run(updateQuery)
    }
}
