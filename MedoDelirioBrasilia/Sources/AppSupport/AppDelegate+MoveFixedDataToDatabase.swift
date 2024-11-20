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
        do {
            let soundData: [Sound] = try Bundle.main.decodeJSON("sound_data.json")
            soundData.forEach { sound in
                do {
                    try LocalDatabase.shared.insert(sound: sound)
                } catch {
                    Logger.shared.logSyncError(description: "Erro ao tentar importar Som '\(sound.title)': \(error.localizedDescription)")
                }
            }
            let soundCount = try LocalDatabase.shared.soundCount()
            Logger.shared.logSyncSuccess(description: "\(formatNumber(soundCount)) Sons importados dos dados fixos com sucesso.")
        } catch {
            Logger.shared.logSyncError(description: "Erro ao tentar importar Sons: \(error.localizedDescription)")
        }
    }

    internal func moveAuthorsToDatabase() {
        do {
            let authorData: [Author] = try Bundle.main.decodeJSON("author_data.json")
            authorData.forEach { author in
                do {
                    try LocalDatabase.shared.insert(author: author)
                } catch {
                    Logger.shared.logSyncError(description: "Erro ao tentar importar Autor '\(author.name)': \(error.localizedDescription)")
                }
            }
            let authorCount = try LocalDatabase.shared.getAuthorCount()
            Logger.shared.logSyncSuccess(description: "\(authorCount) Autores importados dos dados fixos com sucesso.")
        } catch {
            Logger.shared.logSyncError(description: "Erro ao tentar importar Autores: \(error.localizedDescription)")
        }
    }
}

extension AppDelegate {

    internal func moveSongsAndMusicGenresToDatabase() {
        moveSongsToDatabase()
        moveMusicGenresToDatabase()
    }

    internal func moveSongsToDatabase() {
        do {
            let songData: [Song] = try Bundle.main.decodeJSON("song_data.json")
            songData.forEach { song in
                do {
                    try LocalDatabase.shared.insert(song: song)
                } catch {
                    Logger.shared.logSyncError(description: "Erro ao tentar importar Música '\(song.title)': \(error.localizedDescription)")
                }
            }
            let songCount = try LocalDatabase.shared.songCount()
            Logger.shared.logSyncSuccess(description: "\(songCount) Músicas importadas dos dados fixos com sucesso.")
        } catch {
            Logger.shared.logSyncError(description: "Erro ao tentar importar Músicas: \(error.localizedDescription)")
        }
    }

    internal func moveMusicGenresToDatabase() {
        do {
            let genreData: [MusicGenre] = try Bundle.main.decodeJSON("musicGenre_data.json")
            genreData.forEach { genre in
                do {
                    try LocalDatabase.shared.insert(genre: genre)
                } catch {
                    Logger.shared.logSyncError(description: "Erro ao tentar importar Gênero Musical '\(genre.name)': \(error.localizedDescription)")
                }
            }
            let genreCount = try LocalDatabase.shared.genreCount()
            Logger.shared.logSyncSuccess(description: "\(genreCount) Gêneros Musicais importados dos dados fixos com sucesso.")
        } catch {
            Logger.shared.logSyncError(description: "Erro ao tentar importar Gêneros Musicais: \(error.localizedDescription)")
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
