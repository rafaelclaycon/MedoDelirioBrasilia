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
                Logger.shared.logSyncError(description: "Problema ao tentar importar Som '\(sound.title)': \(error.localizedDescription)", updateEventId: "")
            }
        }
        if let soundCount = try? LocalDatabase.shared.soundCount() {
            Logger.shared.logSyncSuccess(description: "\(formatNumber(soundCount)) Sons importados dos dados fixos com sucesso.", updateEventId: "")
        }
        
        let authorData: [Author] = Bundle.main.decodeJSON("author_data.json")
        authorData.forEach { author in
            do {
                try LocalDatabase.shared.insert(author: author)
            } catch {
                Logger.shared.logSyncError(description: "Problema ao tentar importar Autor '\(author.name)': \(error.localizedDescription)", updateEventId: "")
            }
        }
        if let authorCount = try? LocalDatabase.shared.getAuthorCount() {
            Logger.shared.logSyncSuccess(description: "\(formatNumber(authorCount)) Autores importados dos dados fixos com sucesso.", updateEventId: "")
        }
    }

    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? ""
    }
}
