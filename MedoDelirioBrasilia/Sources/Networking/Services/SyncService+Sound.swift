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
            try localDatabase.insert(sound: sound)
            
            let fileUrl = URL(string: "http://127.0.0.1:8080/sounds/\(updateEvent.contentId).mp3")!
            let downloadedFileUrl = try await NetworkRabbit.downloadFile(from: fileUrl, into: InternalFolderNames.downloadedSounds)
            print("File downloaded successfully at: \(downloadedFileUrl)")
            
            try localDatabase.markAsSucceeded(updateEventId: updateEvent.id)
        } catch {
            print(error)
            Logger.logSyncError(description: error.localizedDescription, updateEventId: updateEvent.id.uuidString)
        }
    }
    
    func updateSoundMetadata(with updateEvent: UpdateEvent) async {
        let url = URL(string: networkRabbit.serverPath + "v3/sound/\(updateEvent.contentId)")!
        do {
            let sound: Sound = try await NetworkRabbit.get(from: url)
            try localDatabase.update(sound: sound)
            try localDatabase.markAsSucceeded(updateEventId: updateEvent.id)
        } catch {
            print(error)
            Logger.logSyncError(description: error.localizedDescription, updateEventId: updateEvent.id.uuidString)
        }
    }
    
    func updateSoundFile(_ updateEvent: UpdateEvent) {
        print("File updated - Not implemented yet")
    }
    
    func deleteSound(_ updateEvent: UpdateEvent) {
        do {
            try localDatabase.delete(soundId: updateEvent.contentId)
            try removeSoundFile(named: "\(updateEvent.contentId).mp3")
            try localDatabase.markAsSucceeded(updateEventId: updateEvent.id)
        } catch {
            print(error)
            Logger.logSyncError(description: error.localizedDescription, updateEventId: updateEvent.id.uuidString)
        }
    }
    
    private func removeSoundFile(named filename: String) throws {
        let documentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileManager = FileManager.default
        let file = documentsFolder.appendingPathComponent(filename)
        
        if fileManager.fileExists(atPath: file.path) {
            try fileManager.removeItem(at: file)
        }
    }
}
