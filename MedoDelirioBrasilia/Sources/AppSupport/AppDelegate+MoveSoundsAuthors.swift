//
//  AppDelegate+MoveSoundsAuthors.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 28/04/23.
//

import Foundation

extension AppDelegate {
    
    internal func moveSoundsAndAuthorsToDatabase() {
        let soundData: [Sound] = Bundle.main.decodeJSON("sound_data.json")
        soundData.forEach { sound in
            do {
                try database.insert(sound: sound)
            } catch {
                Logger.logSyncError(description: "Problem inserting Sound '\(sound.title)': \(error.localizedDescription)", updateEventId: "")
            }
        }
        if let soundCount = try? database.soundCount() {
            Logger.logSyncSuccess(description: "\(soundCount) Sounds imported from fixed data successfully.", updateEventId: "")
        }
        
        authorData.forEach { author in
            do {
                try database.insert(author: author)
            } catch {
                Logger.logSyncError(description: "Problem inserting Author '\(author.name)': \(error.localizedDescription)", updateEventId: "")
            }
        }
        if let authorCount = try? database.getAuthorCount() {
            Logger.logSyncSuccess(description: "\(authorCount) Authors imported from fixed data successfully.", updateEventId: "")
        }
    }
}
