//
//  AddPinnedReactionTable.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 17/11/24.
//

import Foundation
import SQLiteMigrationManager
import SQLite

private typealias Expression = SQLite.Expression

struct AddPinnedReactionTable: Migration {

    var version: Int64 = 2024_11_17_09_35_00

    private var pinnedReaction = Table("pinnedReaction")

    func migrateDatabase(_ db: Connection) throws {
        try createPinnedReactionTable(db)
    }

    private func createPinnedReactionTable(_ db: Connection) throws {
        let id = Expression<String>("id")
        let reactionId = Expression<String>("reactionId")
        let reactionName = Expression<String>("reactionName")
        let addedAt = Expression<Date>("addedAt")

        try db.run(pinnedReaction.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(reactionId)
            t.column(reactionName)
            t.column(addedAt)
        })
    }
}
