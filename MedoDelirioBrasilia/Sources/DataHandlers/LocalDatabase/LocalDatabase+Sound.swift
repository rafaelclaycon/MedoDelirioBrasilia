//
//  LocalDatabase+Sound.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 28/04/23.
//

import Foundation

extension LocalDatabase {

    func getSoundCount() throws -> Int {
        try db.scalar(sound.count)
    }
    
    func insert(sound newSound: Sound) throws {
        let insert = try sound.insert(newSound)
        try db.run(insert)
    }
    
    func getAllSounds() throws -> [Sound] {
        var queriedSounds = [Sound]()
        for queriedSound in try db.prepare(sound) {
            queriedSounds.append(try queriedSound.decode())
        }
        return queriedSounds
    }
}
