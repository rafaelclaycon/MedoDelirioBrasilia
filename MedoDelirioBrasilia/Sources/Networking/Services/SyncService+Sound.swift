//
//  SyncService+Sound.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 22/05/23.
//

import Foundation

extension SyncService {
    
    func createSound(from updateEvent: UpdateEvent) async {
        let url = URL(string: networkRabbit.serverPath + "v3/sound/\(updateEvent.contentId)")!
        do {
            let sound: Sound = try await NetworkRabbit.get(from: url)
            try injectedDatabase.insert(sound: sound)
            
            try await downloadFile(updateEvent.contentId)
            
            try injectedDatabase.markAsSucceeded(updateEventId: updateEvent.id)
        } catch {
            print(error)
            Logger.logSyncError(description: error.localizedDescription, updateEventId: updateEvent.id.uuidString)
        }
    }
    
    func updateSoundMetadata(with updateEvent: UpdateEvent) async {
        let url = URL(string: networkRabbit.serverPath + "v3/sound/\(updateEvent.contentId)")!
        do {
            let sound: Sound = try await NetworkRabbit.get(from: url)
            try injectedDatabase.update(sound: sound)
            try injectedDatabase.markAsSucceeded(updateEventId: updateEvent.id)
        } catch {
            print(error)
            Logger.logSyncError(description: error.localizedDescription, updateEventId: updateEvent.id.uuidString)
        }
    }
    
    func updateSoundFile(_ updateEvent: UpdateEvent) async {
        do {
            try await downloadFile(updateEvent.contentId)
            try injectedDatabase.setIsFromServer(to: true, on: updateEvent.contentId)
            try injectedDatabase.markAsSucceeded(updateEventId: updateEvent.id)
        } catch {
            print(error)
            Logger.logSyncError(description: error.localizedDescription, updateEventId: updateEvent.id.uuidString)
        }
    }
    
    func deleteSound(_ updateEvent: UpdateEvent) {
        do {
            try injectedDatabase.delete(soundId: updateEvent.contentId)
            try removeSoundFileIfExists(named: updateEvent.contentId)
            try injectedDatabase.markAsSucceeded(updateEventId: updateEvent.id)
        } catch {
            print(error)
            Logger.logSyncError(description: error.localizedDescription, updateEventId: updateEvent.id.uuidString)
        }
    }
    
    // MARK: - Internal
    
    private func removeSoundFileIfExists(named filename: String) throws {
        let documentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileManager = FileManager.default
        let file = documentsFolder.appendingPathComponent("\(InternalFolderNames.downloadedSounds)\(filename).mp3")
        
        if fileManager.fileExists(atPath: file.path) {
            try fileManager.removeItem(at: file)
        }
    }
    
    private func downloadFile(_ contentId: String) async throws {
        let fileUrl = URL(string: "http://127.0.0.1:8080/sounds/\(contentId).mp3")!
        
        try removeSoundFileIfExists(named: contentId)
        
        let downloadedFileUrl = try await NetworkRabbit.downloadFile(from: fileUrl, into: InternalFolderNames.downloadedSounds)
        print("File downloaded successfully at: \(downloadedFileUrl)")
    }
}
