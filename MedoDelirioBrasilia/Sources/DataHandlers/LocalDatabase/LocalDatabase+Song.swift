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
        let genre_id_on_genre_table = Expression<String>("id")
        let genre_name = Expression<String>("name")
        let isOffensive = Expression<Bool>("isOffensive")
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        var query = songTable.select(songTable[*], musicGenreTable[genre_name]).join(musicGenreTable, on: songTable[genre_id] == musicGenreTable[genre_id_on_genre_table])

        if !allowSensitive {
            query = query.filter(isOffensive == false)
        }

        for queriedSong in try db.prepare(query) {
            var song: Song = try queriedSong.decode()

            if let dateString = try queriedSong.get(Expression<String?>("dateAdded")) {
                if let date = dateFormatter.date(from: dateString) {
                    song.dateAdded = date
                }
            }

            if let isFromServer = try queriedSong.get(Expression<Bool?>("isFromServer")) {
                song.isFromServer = isFromServer
            }

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

    func update(song updatedSong: Song) throws {
        let id = Expression<String>("id")
        let query = songTable.filter(id == updatedSong.id)
        let updateQuery = query.update(
            Expression<String>("title") <- updatedSong.title,
            Expression<String>("description") <- updatedSong.description,
            Expression<String>("genreId") <- updatedSong.genreId,
            Expression<Double>("duration") <- updatedSong.duration,
            Expression<Bool>("isOffensive") <- updatedSong.isOffensive
        )
        try db.run(updateQuery)
    }

    func delete(songId: String) throws {
        let id = Expression<String>("id")

        let query = songTable.filter(id == songId)
        let count = try db.scalar(query.count)

        if count != 0 {
            try db.run(query.delete())
        } else {
            throw LocalDatabaseError.songNotFound
        }
    }

    func setIsFromServer(to value: Bool, onSongId songId: String) throws {
        let id = Expression<String>("id")
        let query = songTable.filter(id == songId)
        let updateQuery = query.update(
            Expression<Bool>("isFromServer") <- value
        )
        try db.run(updateQuery)
    }
}
