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

    func songs(allowSensitive: Bool) throws -> [Song] {
        var queriedGenres = [Song]()

        let genre_id = Expression<String>("genreId")
        let song_id = Expression<String>("song.id")
        let genre_id_on_genre_table = Expression<String>("id")
        let genre_name = Expression<String>("name")
        let isOffensive = Expression<Bool>("isOffensive")

        var query = songTable.select(songTable[*], musicGenreTable[genre_name]).join(musicGenreTable, on: songTable[genre_id] == musicGenreTable[genre_id_on_genre_table])

        if !allowSensitive {
            query = query.filter(isOffensive == false)
        }

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

    func song(withId songId: String) throws -> Song? {
        var queriedSongs = [Song]()

        let name = Expression<String>("name")
        let genre_id = Expression<String>("genreId")
        let id = Expression<String>("id")

        let query = songTable.select(songTable[*], musicGenreTable[name]).join(musicGenreTable, on: songTable[genre_id] == musicGenreTable[id]).filter(id == songId)

        for queriedSong in try db.prepare(query) {
            var song: Song = try queriedSong.decode()
            song.genreName = try queriedSong.get(name)
            queriedSongs.append(song)
        }
        return queriedSongs.first
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
