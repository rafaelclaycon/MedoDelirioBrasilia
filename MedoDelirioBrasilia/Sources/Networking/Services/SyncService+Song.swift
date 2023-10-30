//
//  SyncService+Song.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 03/09/23.
//

import Foundation

extension SyncService {

    func createSong(from updateEvent: UpdateEvent) async {
        guard
            let contentUrl = URL(string: networkRabbit.serverPath + "v3/song/\(updateEvent.contentId)"),
            let fileUrl = URL(string: baseURL + "songs/\(updateEvent.contentId).mp3")
        else { return }

        do {
            let song: Song = try await NetworkRabbit.get(from: contentUrl)
            try injectedDatabase.insert(song: song)

            try await SyncService.downloadFile(
                at: fileUrl,
                to: InternalFolderNames.downloadedSongs,
                contentId: updateEvent.contentId
            )

            try injectedDatabase.markAsSucceeded(updateEventId: updateEvent.id)
            Logger.shared.logSyncSuccess(description: "Música \"\(song.title)\" criada com sucesso.", updateEventId: updateEvent.id.uuidString)
        } catch {
            Logger.shared.logSyncError(description: "Erro ao tentar criar Música: \(error.localizedDescription)", updateEventId: updateEvent.id.uuidString)
        }
    }

    func updateSongMetadata(with updateEvent: UpdateEvent) async {
        let url = URL(string: networkRabbit.serverPath + "v3/song/\(updateEvent.contentId)")!
        do {
            let song: Song = try await NetworkRabbit.get(from: url)
            try injectedDatabase.update(song: song)
            try injectedDatabase.markAsSucceeded(updateEventId: updateEvent.id)
            Logger.shared.logSyncSuccess(description: "Metadados da Música \"\(song.title)\" atualizados com sucesso.", updateEventId: updateEvent.id.uuidString)
        } catch {
            print(error)
            Logger.shared.logSyncError(description: error.localizedDescription, updateEventId: updateEvent.id.uuidString)
        }
    }

    func updateSongFile(_ updateEvent: UpdateEvent) async {
        guard let fileUrl = URL(string: baseURL + "songs/\(updateEvent.contentId).mp3") else { return }
        do {
            try await SyncService.downloadFile(
                at: fileUrl,
                to: InternalFolderNames.downloadedSongs,
                contentId: updateEvent.contentId
            )
            try injectedDatabase.setIsFromServer(to: true, onSongId: updateEvent.contentId)
            try injectedDatabase.markAsSucceeded(updateEventId: updateEvent.id)
            Logger.shared.logSyncSuccess(description: "Arquivo da Música \"\(updateEvent.contentId)\" atualizado.", updateEventId: updateEvent.id.uuidString)
        } catch {
            print(error)
            Logger.shared.logSyncError(description: error.localizedDescription, updateEventId: updateEvent.id.uuidString)
        }
    }

    func deleteSong(_ updateEvent: UpdateEvent) {
        do {
            try injectedDatabase.delete(songId: updateEvent.contentId)
            try SyncService.removeContentFile(
                named: updateEvent.contentId,
                atFolder: InternalFolderNames.downloadedSongs
            )
            try injectedDatabase.markAsSucceeded(updateEventId: updateEvent.id)
            Logger.shared.logSyncSuccess(description: "Som \"\(updateEvent.contentId)\" apagado com sucesso.", updateEventId: updateEvent.id.uuidString)
        } catch {
            print(error)
            Logger.shared.logSyncError(description: error.localizedDescription, updateEventId: updateEvent.id.uuidString)
        }
    }
}
