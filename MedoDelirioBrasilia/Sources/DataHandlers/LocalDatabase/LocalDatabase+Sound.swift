//
//  LocalDatabase+Sound.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 28/04/23.
//

import Foundation
import SQLite

extension LocalDatabase {

    func soundCount() throws -> Int {
        try db.scalar(sound.count)
    }
    
    func insert(sound newSound: Sound) throws {
        let insert = try sound.insert(newSound)
        try db.run(insert)
    }
    
    func allSounds() throws -> [Sound] {
        var queriedSounds = [Sound]()
        
        let author_id = Expression<String>("authorId")
        let id = Expression<String>("id")
        let name = Expression<String>("name")

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        for queriedSound in try db.prepare(sound.select(sound[*], author[name]).join(author, on: sound[author_id] == author[id])) {
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
        
        let query = sound.select(sound[*], author[name]).join(author, on: sound[author_id] == author[id]).filter(id == soundId)
        for queriedSound in try db.prepare(query) {
            var soundData: Sound = try queriedSound.decode()
            let authorName = try queriedSound.get(author[name])
            soundData.authorName = authorName
            queriedSounds.append(soundData)
        }
        return queriedSounds.first
    }
    
    func sounds(withIds soundIds: [String]) throws -> [Sound] {
        var queriedSounds = [Sound]()
        
        let author_id = Expression<String>("authorId")
        let id = Expression<String>("id")
        let name = Expression<String>("name")
        
        let query = sound
            .select(sound[*], author[name])
            .join(author, on: sound[author_id] == author[id])
            .filter(soundIds.contains(sound[id]))
        
        for queriedSound in try db.prepare(query) {
            var soundData: Sound = try queriedSound.decode()
            let authorName = try queriedSound.get(author[name])
            soundData.authorName = authorName
            queriedSounds.append(soundData)
        }
        return queriedSounds
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

        var query = sound
            .select(sound[*], author[name])
            .join(author, on: sound[author_id] == author[id])
            .filter(author_id == authorId)

        if !isSensitiveContentAllowed {
            query = query.filter(is_offensive == false)
        }

        for queriedSound in try db.prepare(query) {
            var soundData: Sound = try queriedSound.decode()
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
        let query = sound.filter(id == updatedSound.id)
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
        let deleteQuery = sound.filter(id == soundId).delete()
        try db.run(deleteQuery)
    }
    
    func setIsFromServer(to value: Bool, on soundId: String) throws {
        let id = Expression<String>("id")
        let query = sound.filter(id == soundId)
        let updateQuery = query.update(
            Expression<Bool>("isFromServer") <- value
        )
        try db.run(updateQuery)
    }
}