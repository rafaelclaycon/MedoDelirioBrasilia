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
                try LocalDatabase.shared.insert(sound: sound)
            } catch {
                Logger.shared.logSyncError(description: "Problem inserting Sound '\(sound.title)': \(error.localizedDescription)", updateEventId: "")
            }
        }
        if let soundCount = try? LocalDatabase.shared.soundCount() {
            Logger.shared.logSyncSuccess(description: "\(soundCount) Sounds imported from fixed data successfully.", updateEventId: "")
        }
        
        let authorData: [Author] = Bundle.main.decodeJSON("author_data.json")
        authorData.forEach { author in
            do {
                try LocalDatabase.shared.insert(author: author)
            } catch {
                Logger.shared.logSyncError(description: "Problem inserting Author '\(author.name)': \(error.localizedDescription)", updateEventId: "")
            }
        }
        if let authorCount = try? LocalDatabase.shared.getAuthorCount() {
            Logger.shared.logSyncSuccess(description: "\(authorCount) Authors imported from fixed data successfully.", updateEventId: "")
        }
    }
}
