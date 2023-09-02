//
//  LocalDatabase+MusicGenre.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 02/09/23.
//

import Foundation
import SQLite

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
