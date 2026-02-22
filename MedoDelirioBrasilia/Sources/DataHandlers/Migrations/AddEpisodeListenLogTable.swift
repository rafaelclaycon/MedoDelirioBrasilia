//
//  AddEpisodeListenLogTable.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 17/02/26.
//

import Foundation
import SQLiteMigrationManager
import SQLite

private typealias Expression = SQLite.Expression

struct AddEpisodeListenLogTable: Migration {

    var version: Int64 = 2026_02_22_10_00_00

    private var episodeListenLog = Table("episodeListenLog")

    func migrateDatabase(_ db: Connection) throws {
        let id = Expression<String>("id")
        let episodeId = Expression<String>("episodeId")
        let startedAt = Expression<Date>("startedAt")
        let endedAt = Expression<Date>("endedAt")
        let durationListened = Expression<Double>("durationListened")
        let didComplete = Expression<Bool>("didComplete")

        try db.run(episodeListenLog.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(episodeId)
            t.column(startedAt)
            t.column(endedAt)
            t.column(durationListened)
            t.column(didComplete)
        })

        try db.run(episodeListenLog.createIndex(episodeId, ifNotExists: true))
    }
}
