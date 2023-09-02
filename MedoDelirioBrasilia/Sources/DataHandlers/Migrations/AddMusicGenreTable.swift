//
//  AddMusicGenreTable.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 02/09/23.
//

import Foundation
import SQLiteMigrationManager
import SQLite

struct AddMusicGenreTable: Migration {

    var version: Int64 = 2023_09_02_01_47_00

    private var musicGenreTable = Table("musicGenre")

    func migrateDatabase(_ db: Connection) throws {
        try createMusicGenreTable(db)
    }

    private func createMusicGenreTable(_ db: Connection) throws {
        let id = Expression<String>("id")
        let symbol = Expression<String>("symbol")
        let name = Expression<String>("name")
        let is_hidden = Expression<Bool>("isHidden")

        try db.run(musicGenreTable.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(symbol)
            t.column(name)
            t.column(is_hidden)
        })
    }
}
