//
//  ContentFileManager.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 25/05/25.
//

import Foundation

protocol ContentFileManagerProtocol {

    func downloadSound(withId contentId: String) async throws
    func downloadSong(withId contentId: String) async throws

    func removeSoundFile(id: String) throws
    func removeSongFile(id: String) throws
}

final class ContentFileManager: ContentFileManagerProtocol {

    private let fileManager: FileManager
    private let soundsDirectory: URL
    private let songsDirectory: URL

    init(
        fileManager: FileManager = .default
    ) {
        self.fileManager = fileManager
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.soundsDirectory = documentsDirectory.appendingPathComponent(InternalFolderNames.downloadedSounds)
        self.songsDirectory = documentsDirectory.appendingPathComponent(InternalFolderNames.downloadedSongs)
    }

    public func downloadSound(withId contentId: String) async throws {
        let fileUrl = URL(string: APIConfig.baseServerURL + "sounds/\(contentId).mp3")!

        try removeSoundFile(id: contentId)

        let downloadedFileUrl = try await APIClient.downloadFile(from: fileUrl, into: InternalFolderNames.downloadedSounds)
        print("File downloaded successfully at: \(downloadedFileUrl)")
    }

    public func downloadSong(withId contentId: String) async throws {
        let fileUrl = URL(string: APIConfig.baseServerURL + "songs/\(contentId).mp3")!

        try removeSoundFile(id: contentId)

        let downloadedFileUrl = try await APIClient.downloadFile(from: fileUrl, into: InternalFolderNames.downloadedSongs)
        print("File downloaded successfully at: \(downloadedFileUrl)")
    }

    public func removeSoundFile(id: String) throws {
        if let fileURL = soundFileURL(id: id) {
            try fileManager.removeItem(at: fileURL)
        }
    }

    public func removeSongFile(id: String) throws {
        if let fileURL = songFileURL(id: id) {
            try fileManager.removeItem(at: fileURL)
        }
    }

    private func soundFileURL(id: String) -> URL? {
        let fileURL = soundsDirectory.appendingPathComponent("\(id).mp3")
        return fileManager.fileExists(atPath: fileURL.path) ? fileURL : nil
    }

    private func songFileURL(id: String) -> URL? {
        let fileURL = songsDirectory.appendingPathComponent("\(id).mp3")
        return fileManager.fileExists(atPath: fileURL.path) ? fileURL : nil
    }
}
