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

    func lastFewLogs() -> [SyncLog] {
        var syncLogs: [SyncLog] = []

        let id = Expression<String>("id")
        let log_type = Expression<String>("logType")
        let description = Expression<String>("description")
        let date_time = Expression<String>("dateTime")
        let update_event_id = Expression<String>("updateEventId")

        do {
            for row in try db.prepare(syncLogTable.order(date_time.desc).limit(20)) { // .filter(log_type == "\"error\"")
                syncLogs.append(
                    SyncLog(
                        id: row[id],
                        logType: row[log_type] == "\"success\"" ? .success : .error,
                        description: row[description],
                        dateTime: row[date_time],
                        updateEventId: row[update_event_id]
                    )
                )
            }
        } catch {
            print(error)
        }
        return syncLogs
    }
}
