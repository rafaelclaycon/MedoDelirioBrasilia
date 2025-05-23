//
//  LocalDatabase+Sound.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 28/04/23.
//

import Foundation
import SQLite

private typealias Expression = SQLite.Expression

extension LocalDatabase {

    func soundCount() throws -> Int {
        try db.scalar(soundTable.count)
    }

    func insert(sound newSound: Sound) throws {
        let insert = try soundTable.insert(newSound)
        try db.run(insert)
    }

    func sounds(
        allowSensitive: Bool
    ) throws -> [Sound] {
        var queriedSounds = [Sound]()

        let author_id = Expression<String>("authorId")
        let id = Expression<String>("id")
        let name = Expression<String>("name")
        let isOffensive = Expression<Bool>("isOffensive")

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        var query = soundTable.select(soundTable[*], author[name])
            .join(author, on: soundTable[author_id] == author[id])

        if !allowSensitive {
            query = query.filter(isOffensive == false)
        }

        for queriedSound in try db.prepare(query) {
            var soundData: Sound = try queriedSound.decode()

            if let dateString = try queriedSound.get(Expression<String?>("dateAdded")) {
                if let date = dateFormatter.date(from: dateString) {
                    soundData.dateAdded = date
                }
            }

            if let isFromServer = try queriedSound.get(Expression<Bool?>("isFromServer")) {
                soundData.isFromServer = isFromServer
            }

            let authorName = try queriedSound.get(author[name])
            soundData.authorName = authorName

            queriedSounds.append(soundData)
        }
        return queriedSounds
    }

    func sound(withId soundId: String) throws -> Sound? {
        var queriedSounds = [Sound]()

        let author_id = Expression<String>("authorId")
        let id = Expression<String>("id")
        let name = Expression<String>("name")

        let query = soundTable.select(soundTable[*], author[name])
            .join(author, on: soundTable[author_id] == author[id])
            .filter(soundTable[id] == soundId)

        for queriedSound in try db.prepare(query) {
            var soundData: Sound = try queriedSound.decode()
            if let dateString = try queriedSound.get(Expression<String?>("dateAdded")) {
                if let date = dateFormatter.date(from: dateString) {
                    soundData.dateAdded = date
                }
            }
            if let isFromServer = try queriedSound.get(Expression<Bool?>("isFromServer")) {
                soundData.isFromServer = isFromServer
            }
            let authorName = try queriedSound.get(author[name])
            soundData.authorName = authorName
            queriedSounds.append(soundData)
        }
        return queriedSounds.first
    }

    func sounds(withIds soundIds: [String]) throws -> [Sound] {
        var queriedSounds = [String: Sound]()

        let author_id = Expression<String>("authorId")
        let id = Expression<String>("id")
        let name = Expression<String>("name")

        let query = soundTable
            .select(soundTable[*], author[name])
            .join(author, on: soundTable[author_id] == author[id])
            .filter(soundIds.contains(soundTable[id]))

        for queriedSound in try db.prepare(query) {
            var soundData: Sound = try queriedSound.decode()
            if let dateString = try queriedSound.get(Expression<String?>("dateAdded")) {
                if let date = dateFormatter.date(from: dateString) {
                    soundData.dateAdded = date
                }
            }
            if let isFromServer = try queriedSound.get(Expression<Bool?>("isFromServer")) {
                soundData.isFromServer = isFromServer
            }
            let authorName = try queriedSound.get(author[name])
            soundData.authorName = authorName

            let soundId = try queriedSound.get(id)
            queriedSounds[soundId] = soundData
        }

        var orderedSounds = [Sound]()
        for soundId in soundIds {
            if let sound = queriedSounds[soundId] {
                orderedSounds.append(sound)
            }
        }

        return orderedSounds
    }

    func allSounds(
        forAuthor authorId: String,
        isSensitiveContentAllowed: Bool
    ) throws -> [Sound] {
        var queriedSounds = [Sound]()

        let author_id = Expression<String>("authorId")
        let id = Expression<String>("id")
        let name = Expression<String>("name")
        let is_offensive = Expression<Bool>("isOffensive")

        var query = soundTable
            .select(soundTable[*], author[name])
            .join(author, on: soundTable[author_id] == author[id])
            .filter(author_id == authorId)

        if !isSensitiveContentAllowed {
            query = query.filter(is_offensive == false)
        }

        for queriedSound in try db.prepare(query) {
            var soundData: Sound = try queriedSound.decode()
            if let dateString = try queriedSound.get(Expression<String?>("dateAdded")) {
                if let date = dateFormatter.date(from: dateString) {
                    soundData.dateAdded = date
                }
            }
            if let isFromServer = try queriedSound.get(Expression<Bool?>("isFromServer")) {
                soundData.isFromServer = isFromServer
            }
            let authorName = try queriedSound.get(author[name])
            soundData.authorName = authorName
            queriedSounds.append(soundData)
        }
        return queriedSounds
    }

//    func update(sound updatedSound: Sound) throws {
//        let id = Expression<String>("id")
//        let filter = sound.filter(id == updatedSound.id)
//        let update = try filter.update(updatedSound)
//        try db.run(update)
//    }

    func update(sound updatedSound: Sound) throws {
        let id = Expression<String>("id")
        let query = soundTable.filter(id == updatedSound.id)
        let updateQuery = query.update(
            Expression<String>("title") <- updatedSound.title,
            Expression<String>("authorId") <- updatedSound.authorId,
            Expression<String>("description") <- updatedSound.description,
            Expression<Double>("duration") <- updatedSound.duration,
            Expression<Bool>("isOffensive") <- updatedSound.isOffensive
        )

        try db.run(updateQuery)
    }

    func delete(soundId: String) throws {
        let id = Expression<String>("id")
        let deleteQuery = soundTable.filter(id == soundId).delete()
        try db.run(deleteQuery)
    }

    func setIsFromServer(to value: Bool, onSoundId soundId: String) throws {
        let id = Expression<String>("id")
        let query = soundTable.filter(id == soundId)
        let updateQuery = query.update(
            Expression<Bool>("isFromServer") <- value
        )
        try db.run(updateQuery)
    }

    func randomSound(
        includeOffensive: Bool
    ) throws -> Sound? {
        let author_id = Expression<String>("authorId")
        let id = Expression<String>("id")
        let name = Expression<String>("name")
        let is_offensive = Expression<Bool>("isOffensive")

        let query = soundTable
            .select(soundTable[*], author[name])
            .join(author, on: soundTable[author_id] == author[id])
            .where(soundTable[is_offensive] == includeOffensive)
            .order(Expression<Void>(literal: "RANDOM()")) // SQLite's RANDOM() function to order the sounds randomly
            .limit(1)

        // Fetch and decode a single result into a Sound object
        if let queriedSound = try db.pluck(query) {
            var soundData: Sound = try queriedSound.decode()

            // Optional fields: dateAdded and isFromServer
            if let dateString = try queriedSound.get(Expression<String?>("dateAdded")) {
                if let date = dateFormatter.date(from: dateString) {
                    soundData.dateAdded = date
                }
            }
            if let isFromServer = try queriedSound.get(Expression<Bool?>("isFromServer")) {
                soundData.isFromServer = isFromServer
            }

            // Set author name
            let authorName = try queriedSound.get(author[name])
            soundData.authorName = authorName

            return soundData
        }
        return nil // Return nil if no sound is found
    }

    func contentExists(withId contentId: String) throws -> Bool {
        let id = Expression<String>("id")
        let query = soundTable.filter(id == contentId)
        let count = try db.scalar(query.count)
        return count > 0
    }
}
