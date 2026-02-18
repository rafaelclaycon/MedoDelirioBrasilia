//
//  AddEpisodeStateTables.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 18/02/26.
//

import Foundation
import SQLiteMigrationManager
import SQLite

private typealias Expression = SQLite.Expression

struct AddEpisodeStateTables: Migration {

    var version: Int64 = 2026_02_18_10_00_00

    private var episodeFavorite = Table("episodeFavorite")
    private var episodePlayed = Table("episodePlayed")
    private var episodeProgress = Table("episodeProgress")

    func migrateDatabase(_ db: Connection) throws {
        try createEpisodeFavoriteTable(db)
        try createEpisodePlayedTable(db)
        try createEpisodeProgressTable(db)
    }

    private func createEpisodeFavoriteTable(_ db: Connection) throws {
        let episodeId = Expression<String>("episodeId")
        let dateAdded = Expression<Date>("dateAdded")

        try db.run(episodeFavorite.create(ifNotExists: true) { t in
            t.column(episodeId, primaryKey: true)
            t.column(dateAdded)
        })
    }

    private func createEpisodePlayedTable(_ db: Connection) throws {
        let episodeId = Expression<String>("episodeId")
        let dateMarked = Expression<Date>("dateMarked")

        try db.run(episodePlayed.create(ifNotExists: true) { t in
            t.column(episodeId, primaryKey: true)
            t.column(dateMarked)
        })
    }

    private func createEpisodeProgressTable(_ db: Connection) throws {
        let episodeId = Expression<String>("episodeId")
        let currentTime = Expression<Double>("currentTime")
        let duration = Expression<Double>("duration")
        let updatedAt = Expression<Date>("updatedAt")

        try db.run(episodeProgress.create(ifNotExists: true) { t in
            t.column(episodeId, primaryKey: true)
            t.column(currentTime)
            t.column(duration)
            t.column(updatedAt)
        })
    }
}
