//
//  LocalDatabase+Song.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 02/09/23.
//

import Foundation
import SQLite

extension LocalDatabase {

    func insert(song newSong: Song) throws {
        let insert = try songTable.insert(newSong)
        try db.run(insert)
    }

    func songs() throws -> [Song] {
        var queriedGenres = [Song]()

        let genre_id = Expression<String>("genreId")
        let id = Expression<String>("id")
        let genre_name = Expression<String>("name")

        let query = songTable.join(musicGenreTable, on: songTable[genre_id] == musicGenreTable[id])

        for queriedSong in try db.prepare(query) {
            var song: Song = try queriedSong.decode()
            song.genreName = try queriedSong.get(musicGenreTable[genre_name])
            queriedGenres.append(song)
        }
        return queriedGenres
    }

    func songCount() throws -> Int {
        try db.scalar(songTable.count)
    }

//    func update(author updatedAuthor: Author) throws {
//        let id = Expression<String>("id")
//        let query = author.filter(id == updatedAuthor.id)
//        let updateQuery = query.update(
//            Expression<String>("name") <- updatedAuthor.name,
//            Expression<String?>("photo") <- updatedAuthor.photo,
//            Expression<String?>("description") <- updatedAuthor.description
//        )
//        try db.run(updateQuery)
//    }
//
//    func delete(authorId: String) throws {
//        let id = Expression<String>("id")
//
//        let query = author.filter(id == authorId)
//        let count = try db.scalar(query.count)
//
//        if count != 0 {
//            try db.run(query.delete())
//        } else {
//            throw LocalDatabaseError.authorNotFound
//        }
//    }
}
