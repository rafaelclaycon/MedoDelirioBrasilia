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
            let contentUrl = URL(string: APIClient.shared.serverPath + "v3/song/\(updateEvent.contentId)"),
            let fileUrl = URL(string: APIConfig.baseServerURL + "songs/\(updateEvent.contentId).mp3")
        else { return }

        do {
            let song: Song = try await APIClient.shared.get(from: contentUrl)
            try database.insert(song: song)

            try await SyncService.downloadFile(
                at: fileUrl,
                to: InternalFolderNames.downloadedSongs,
                contentId: updateEvent.contentId
            )

            try database.markAsSucceeded(updateEventId: updateEvent.id)
            Logger.shared.logSyncSuccess(description: "Música \"\(song.title)\" criada com sucesso.", updateEventId: updateEvent.id.uuidString)
        } catch {
            Logger.shared.logSyncError(description: "Erro ao tentar criar Música: \(error.localizedDescription)", updateEventId: updateEvent.id.uuidString)
        }
    }

    func updateSongMetadata(with updateEvent: UpdateEvent) async {
        let url = URL(string: APIClient.shared.serverPath + "v3/song/\(updateEvent.contentId)")!
        do {
            let song: Song = try await APIClient.shared.get(from: url)
            try database.update(song: song)
            try database.markAsSucceeded(updateEventId: updateEvent.id)
            Logger.shared.logSyncSuccess(description: "Metadados da Música \"\(song.title)\" atualizados com sucesso.", updateEventId: updateEvent.id.uuidString)
        } catch {
            print(error)
            Logger.shared.logSyncError(description: error.localizedDescription, updateEventId: updateEvent.id.uuidString)
        }
    }

    func updateSongFile(_ updateEvent: UpdateEvent) async {
        guard let fileUrl = URL(string: APIConfig.baseServerURL + "songs/\(updateEvent.contentId).mp3") else { return }
        do {
            try await SyncService.downloadFile(
                at: fileUrl,
                to: InternalFolderNames.downloadedSongs,
                contentId: updateEvent.contentId
            )
            try database.setIsFromServer(to: true, onSongId: updateEvent.contentId)
            try database.markAsSucceeded(updateEventId: updateEvent.id)
            Logger.shared.logSyncSuccess(description: "Arquivo da Música \"\(updateEvent.contentId)\" atualizado.", updateEventId: updateEvent.id.uuidString)
        } catch {
            print(error)
            Logger.shared.logSyncError(description: error.localizedDescription, updateEventId: updateEvent.id.uuidString)
        }
    }

    func deleteSong(_ updateEvent: UpdateEvent) {
        do {
            try database.delete(songId: updateEvent.contentId)
            try SyncService.removeContentFile(
                named: updateEvent.contentId,
                atFolder: InternalFolderNames.downloadedSongs
            )
            try database.markAsSucceeded(updateEventId: updateEvent.id)
            Logger.shared.logSyncSuccess(description: "Som \"\(updateEvent.contentId)\" apagado com sucesso.", updateEventId: updateEvent.id.uuidString)
        } catch {
            print(error)
            Logger.shared.logSyncError(description: error.localizedDescription, updateEventId: updateEvent.id.uuidString)
        }
    }
}
