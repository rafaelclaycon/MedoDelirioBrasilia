//
//  AppDelegate+MoveFixedDataToDatabase.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 28/04/23.
//

import Foundation

extension AppDelegate {

    internal func moveSoundsAndAuthorsToDatabase() {
        moveSoundsToDatabase()
        moveAuthorsToDatabase()
    }

    internal func moveSoundsToDatabase() {
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
    }

    internal func moveAuthorsToDatabase() {
        let authorData: [Author] = Bundle.main.decodeJSON("author_data.json")
        authorData.forEach { author in
            do {
                try LocalDatabase.shared.insert(author: author)
            } catch {
                Logger.shared.logSyncError(description: "Problema ao tentar importar Autor '\(author.name)': \(error.localizedDescription)", updateEventId: "")
            }
        }
        if let authorCount = try? LocalDatabase.shared.getAuthorCount() {
            Logger.shared.logSyncSuccess(description: "\(authorCount) Autores importados dos dados fixos com sucesso.", updateEventId: "")
        }
    }
}

extension AppDelegate {

    internal func moveSongsAndMusicGenresToDatabase() {
        moveSongsToDatabase()
        moveMusicGenresToDatabase()
    }

    internal func moveSongsToDatabase() {
        let songData: [Song] = Bundle.main.decodeJSON("song_data.json")
        songData.forEach { song in
            do {
                try LocalDatabase.shared.insert(song: song)
            } catch {
                Logger.shared.logSyncError(description: "Problema ao tentar importar Música '\(song.title)': \(error.localizedDescription)", updateEventId: "")
            }
        }
        if let songCount = try? LocalDatabase.shared.songCount() {
            Logger.shared.logSyncSuccess(description: "\(formatNumber(songCount)) Músicas importadas dos dados fixos com sucesso.", updateEventId: "")
        }
    }

    internal func moveMusicGenresToDatabase() {
        let genreData: [MusicGenre] = Bundle.main.decodeJSON("musicGenre_data.json")
        genreData.forEach { genre in
            do {
                try LocalDatabase.shared.insert(genre: genre)
            } catch {
                Logger.shared.logSyncError(description: "Problema ao tentar importar Gênero Musical '\(genre.name)': \(error.localizedDescription)", updateEventId: "")
            }
        }
        if let genreCount = try? LocalDatabase.shared.genreCount() {
            Logger.shared.logSyncSuccess(description: "\(genreCount) Gêneros Musicais importados dos dados fixos com sucesso.", updateEventId: "")
        }
    }
}

extension AppDelegate {

    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? ""
    }
}
