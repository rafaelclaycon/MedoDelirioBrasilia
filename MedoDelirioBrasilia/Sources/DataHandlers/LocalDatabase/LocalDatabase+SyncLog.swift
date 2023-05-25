//
//  LocalDatabase+SyncLog.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 24/05/23.
//

import Foundation
import SQLite

extension LocalDatabase {
    
    func insert(syncLog newSyncLog: SyncLog) {
        do {
            let insert = try syncLogTable.insert(newSyncLog)
            try db.run(insert)
        } catch {
            print(error)
        }
    }
}
