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
        for queriedSound in try db.prepare(sound) {
            queriedSounds.append(try queriedSound.decode())
        }
        return queriedSounds
    }
    
    func sound(withId soundId: String) throws -> Sound? {
        var queriedSounds = [Sound]()
        let id = Expression<String>("id")
        let query = sound.filter(id == soundId)
        for queriedSound in try db.prepare(query) {
            queriedSounds.append(try queriedSound.decode())
        }
        return queriedSounds.first
    }
}
