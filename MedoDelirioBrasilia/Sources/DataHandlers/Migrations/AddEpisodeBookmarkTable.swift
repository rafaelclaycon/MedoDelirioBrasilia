//
//  AddEpisodeBookmarkTable.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 18/02/26.
//

import Foundation
import SQLiteMigrationManager
import SQLite

private typealias Expression = SQLite.Expression

struct AddEpisodeBookmarkTable: Migration {

    var version: Int64 = 2026_02_18_14_00_00

    private var episodeBookmark = Table("episodeBookmark")

    func migrateDatabase(_ db: Connection) throws {
        let id = Expression<String>("id")
        let episodeId = Expression<String>("episodeId")
        let timestamp = Expression<Double>("timestamp")
        let title = Expression<String?>("title")
        let note = Expression<String?>("note")
        let createdAt = Expression<Date>("createdAt")

        try db.run(episodeBookmark.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(episodeId)
            t.column(timestamp)
            t.column(title)
            t.column(note)
            t.column(createdAt)
        })

        try db.run(episodeBookmark.createIndex(episodeId, ifNotExists: true))
    }
}
