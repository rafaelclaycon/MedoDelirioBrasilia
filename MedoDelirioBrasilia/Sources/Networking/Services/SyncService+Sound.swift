//
//  SyncService+Sound.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 22/05/23.
//

import Foundation

extension SyncService {

    func createSound(from updateEvent: UpdateEvent) async {
        let url = URL(string: NetworkRabbit.shared.serverPath + "v3/sound/\(updateEvent.contentId)")!
        do {
            let sound: Sound = try await NetworkRabbit.get(from: url)
            try injectedDatabase.insert(sound: sound)
            
            try await SyncService.downloadFile(updateEvent.contentId)
            
            try injectedDatabase.markAsSucceeded(updateEventId: updateEvent.id)
            Logger.shared.logSyncSuccess(description: "Som \"\(sound.title)\" criado com sucesso.", updateEventId: updateEvent.id.uuidString)
        } catch {
            print(error)
            Logger.shared.logSyncError(description: error.localizedDescription, updateEventId: updateEvent.id.uuidString)
        }
    }

    func updateSoundMetadata(with updateEvent: UpdateEvent) async {
        let url = URL(string: NetworkRabbit.shared.serverPath + "v3/sound/\(updateEvent.contentId)")!
        do {
            let sound: Sound = try await NetworkRabbit.get(from: url)
            try injectedDatabase.update(sound: sound)
            try injectedDatabase.markAsSucceeded(updateEventId: updateEvent.id)
            Logger.shared.logSyncSuccess(description: "Metadados do Som \"\(sound.title)\" atualizados com sucesso.", updateEventId: updateEvent.id.uuidString)
        } catch {
            print(error)
            Logger.shared.logSyncError(description: error.localizedDescription, updateEventId: updateEvent.id.uuidString)
        }
    }

    func updateSoundFile(_ updateEvent: UpdateEvent) async {
        do {
            try await SyncService.downloadFile(updateEvent.contentId)
            try injectedDatabase.setIsFromServer(to: true, onSoundId: updateEvent.contentId)
            try injectedDatabase.markAsSucceeded(updateEventId: updateEvent.id)
            Logger.shared.logSyncSuccess(description: "Arquivo do Som \"\(updateEvent.contentId)\" atualizado.", updateEventId: updateEvent.id.uuidString)
        } catch {
            print(error)
            Logger.shared.logSyncError(description: error.localizedDescription, updateEventId: updateEvent.id.uuidString)
        }
    }

    func deleteSound(_ updateEvent: UpdateEvent) {
        do {
            try injectedDatabase.delete(soundId: updateEvent.contentId)
            try SyncService.removeSoundFileIfExists(named: updateEvent.contentId)
            try injectedDatabase.markAsSucceeded(updateEventId: updateEvent.id)
            Logger.shared.logSyncSuccess(description: "Som \"\(updateEvent.contentId)\" apagado com sucesso.", updateEventId: updateEvent.id.uuidString)
        } catch {
            print(error)
            Logger.shared.logSyncError(description: error.localizedDescription, updateEventId: updateEvent.id.uuidString)
        }
    }

    // MARK: - Internal

    static func removeSoundFileIfExists(named filename: String) throws {
        let documentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileManager = FileManager.default
        let file = documentsFolder.appendingPathComponent("\(InternalFolderNames.downloadedSounds)\(filename).mp3")
        
        if fileManager.fileExists(atPath: file.path) {
            try fileManager.removeItem(at: file)
        }
    }

    static func downloadFile(_ contentId: String) async throws {
        let fileUrl = URL(string: APIConfig.baseServerURL + "sounds/\(contentId).mp3")!
        
        try removeSoundFileIfExists(named: contentId)
        
        let downloadedFileUrl = try await NetworkRabbit.downloadFile(from: fileUrl, into: InternalFolderNames.downloadedSounds)
        print("File downloaded successfully at: \(downloadedFileUrl)")
    }
}
