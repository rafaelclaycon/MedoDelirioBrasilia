//
//  AppDelegate+MoveSoundsAuthors.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 28/04/23.
//

import Foundation

extension AppDelegate {
    
    internal func moveSoundsAndAuthorsToDatabase() -> Bool {
        let soundData: [Sound] = Bundle.main.decodeJSON("sound_data.json")
        soundData.forEach { sound in
            do {
                try database.insert(sound: sound)
            } catch {
                print("Problem inserting Sound '\(sound.title)': \(error.localizedDescription)")
            }
        }
        guard try! database.soundCount() == 1041 else {
            return false
        }
        authorData.forEach { author in
            do {
                try database.insert(author: author)
            } catch {
                print("Problem inserting Author '\(author.name)': \(error.localizedDescription)")
            }
        }
        return try! database.getAuthorCount() == 367
    }
}
