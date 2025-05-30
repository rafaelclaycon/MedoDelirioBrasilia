//
//  LocalDatabase+MusicGenre.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 02/09/23.
//

import Foundation
import SQLite

private typealias Expression = SQLite.Expression

extension LocalDatabase {

    func insert(genre newGenre: MusicGenre) throws {
        let insert = try musicGenreTable.insert(newGenre)
        try db.run(insert)
    }

    func musicGenres() throws -> [MusicGenre] {
        var queriedGenres = [MusicGenre]()
        for queriedGenre in try db.prepare(musicGenreTable) {
            queriedGenres.append(try queriedGenre.decode())
        }
        return queriedGenres
    }

    func genreCount() throws -> Int {
        try db.scalar(musicGenreTable.count)
    }

    func update(genre updatedGenre: MusicGenre) throws {
        let id = Expression<String>("id")
        let query = musicGenreTable.filter(id == updatedGenre.id)
        let updateQuery = query.update(
            Expression<String>("symbol") <- updatedGenre.symbol,
            Expression<String?>("name") <- updatedGenre.name
        )
        try db.run(updateQuery)
    }

    func delete(genreId: String) throws {
        let id = Expression<String>("id")

        let query = musicGenreTable.filter(id == genreId)
        let count = try db.scalar(query.count)

        if count != 0 {
            try db.run(query.delete())
        } else {
            throw LocalDatabaseError.musicGenreNotFound
        }
    }

    func musicGenre(withId genreId: String) throws -> MusicGenre? {
        var queriedItems = [MusicGenre]()
        let id = Expression<String>("id")
        let query = musicGenreTable.filter(id == genreId)
        for queriedItem in try db.prepare(query) {
            queriedItems.append(try queriedItem.decode())
        }
        return queriedItems.first
    }
}
