//
//  SyncService+MusicGenre.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 03/09/23.
//

import Foundation

extension SyncService {

    func createMusicGenre(from updateEvent: UpdateEvent) async {
        let url = URL(string: NetworkRabbit.shared.serverPath + "v3/music-genre/\(updateEvent.contentId)")!
        do {
            let genre: MusicGenre = try await NetworkRabbit.shared.get(from: url)

            try injectedDatabase.insert(genre: genre)
            
            try injectedDatabase.markAsSucceeded(updateEventId: updateEvent.id)
            Logger.shared.logSyncSuccess(description: "Gênero Musical \"\(genre.name)\" criado com sucesso.", updateEventId: updateEvent.id.uuidString)
        } catch {
            Logger.shared.logSyncError(description: error.localizedDescription, updateEventId: updateEvent.id.uuidString)
        }
    }

    func updateGenreMetadata(with updateEvent: UpdateEvent) async {
        let url = URL(string: NetworkRabbit.shared.serverPath + "v3/music-genre/\(updateEvent.contentId)")!
        do {
            let genre: MusicGenre = try await NetworkRabbit.shared.get(from: url)
            try injectedDatabase.update(genre: genre)
            try injectedDatabase.markAsSucceeded(updateEventId: updateEvent.id)
            Logger.shared.logSyncSuccess(description: "Metadados do Gênero Musical \"\(genre.name)\" atualizados com sucesso.", updateEventId: updateEvent.id.uuidString)
        } catch {
            Logger.shared.logSyncError(description: error.localizedDescription, updateEventId: updateEvent.id.uuidString)
        }
    }

    func deleteMusicGenre(with updateEvent: UpdateEvent) async {
        do {
            try injectedDatabase.delete(genreId: updateEvent.contentId)
            try injectedDatabase.markAsSucceeded(updateEventId: updateEvent.id)
            Logger.shared.logSyncSuccess(description: "Gênero Musical \"\(updateEvent.contentId)\" removido com sucesso.", updateEventId: updateEvent.id.uuidString)
        } catch {
            Logger.shared.logSyncError(description: error.localizedDescription, updateEventId: updateEvent.id.uuidString)
        }
    }
}
