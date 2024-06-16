//
//  AddSongAndMusicGenreTables.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 02/09/23.
//

import Foundation
import SQLiteMigrationManager
import SQLite

private typealias Expression = SQLite.Expression

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
        let genre_id = Expression<String>("genreId")
        let duration = Expression<Double>("duration")
        let filename = Expression<String>("filename")
        let date_added = Expression<Date?>("dateAdded")
        let is_offensive = Expression<Bool>("isOffensive")
        let is_from_server = Expression<Bool?>("isFromServer")

        try db.run(songTable.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(title)
            t.column(description)
            t.column(genre_id)
            t.column(duration)
            t.column(filename)
            t.column(date_added)
            t.column(is_offensive)
            t.column(is_from_server)
        })
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
