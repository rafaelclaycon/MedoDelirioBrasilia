//
//  SyncService+Author.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 23/05/23.
//

import Foundation

extension SyncService {
    
    func createAuthor(from updateEvent: UpdateEvent) async {
//        let url = URL(string: networkRabbit.serverPath + "v3/sound/\(updateEvent.contentId)")!
//        do {
//            let sound: Sound = try await NetworkRabbit.get(from: url)
//            try localDatabase.insert(sound: sound)
//            
//            let fileUrl = URL(string: "http://127.0.0.1:8080/sounds/\(updateEvent.contentId).mp3")!
//            let downloadedFileUrl = try await NetworkRabbit.downloadFile(from: fileUrl, into: InternalFolderNames.downloadedSounds)
//            print("File downloaded successfully at: \(downloadedFileUrl)")
//        } catch {
//            print(error)
//            print(error.localizedDescription)
//        }
    }
    
    func updateAuthorMetadata(with updateEvent: UpdateEvent) {
        print("Not implemented yet")
    }
    
    func deleteAuthor(_ updateEvent: UpdateEvent) {
        print("Not implemented yet")
    }
}
