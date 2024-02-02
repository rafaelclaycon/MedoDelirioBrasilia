//
//  AddSongAndMusicGenreTables.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 02/09/23.
//

import Foundation
import SQLiteMigrationManager
import SQLite

// swiftlint:disable identifier_name
struct AddSongAndMusicGenreTables: Migration {

    var version: Int64 = 2023_09_02_01_47_00

    private var songTable = Table("song")
    private var musicGenreTable = Table("musicGenre")

    func migrateDatabase(_ db: Connection) throws {
        try createSongTable(db)
        try createMusicGenreTable(db)
    }

    private func createSongTable(_ db: Connection) throws {
        let id = Expression<String>("id")
        let title = Expression<String>("title")
        let description = Expression<String>("description")
        let genreId = Expression<String>("genreId")
        let duration = Expression<Double>("duration")
        let filename = Expression<String>("filename")
        let dateAdded = Expression<Date?>("dateAdded")
        let isOffensive = Expression<Bool>("isOffensive")
        let isFromServer = Expression<Bool?>("isFromServer")

        try db.run(songTable.create(ifNotExists: true) { table in
            table.column(id, primaryKey: true)
            table.column(title)
            table.column(description)
            table.column(genreId)
            table.column(duration)
            table.column(filename)
            table.column(dateAdded)
            table.column(isOffensive)
            table.column(isFromServer)
        })
    }

    private func createMusicGenreTable(_ db: Connection) throws {
        let id = Expression<String>("id")
        let symbol = Expression<String>("symbol")
        let name = Expression<String>("name")
        let isHidden = Expression<Bool>("isHidden")

        try db.run(musicGenreTable.create(ifNotExists: true) { table in
            table.column(id, primaryKey: true)
            table.column(symbol)
            table.column(name)
            table.column(isHidden)
        })
    }
}
// swiftlint:enable identifier_name
