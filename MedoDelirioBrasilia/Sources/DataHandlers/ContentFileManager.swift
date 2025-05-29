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

//    static func downloadFile(
//        at fileUrl: URL,
//        to localFolderName: String,
//        contentId: String
//    ) async throws {
//        try removeContentFile(named: contentId, atFolder: localFolderName)
//        let downloadedFileUrl = try await APIClient.downloadFile(from: fileUrl, into: localFolderName)
//        print("File downloaded successfully at: \(downloadedFileUrl)")
//    }



    static func downloadFile(_ contentId: String) async throws {
        let fileUrl = URL(string: APIConfig.baseServerURL + "sounds/\(contentId).mp3")!

        try removeSoundFileIfExists(named: contentId)

        let downloadedFileUrl = try await APIClient.downloadFile(from: fileUrl, into: InternalFolderNames.downloadedSounds)
        print("File downloaded successfully at: \(downloadedFileUrl)")
    }

    public func downloadSound(withId contentId: String) async throws {
        let fileUrl = URL(string: APIConfig.baseServerURL + "sounds/\(contentId).mp3")!

        try removeContentFile(named: contentId, atFolder: InternalFolderNames.downloadedSounds)

        let downloadedFileUrl = try await APIClient.downloadFile(from: fileUrl, into: InternalFolderNames.downloadedSounds)
        print("File downloaded successfully at: \(downloadedFileUrl)")
    }

    public func downloadSong(withId contentId: String) async throws {
        let fileUrl = URL(string: APIConfig.baseServerURL + "songs/\(contentId).mp3")!

        try removeContentFile(named: contentId, atFolder: InternalFolderNames.downloadedSounds)

        let downloadedFileUrl = try await APIClient.downloadFile(from: fileUrl, into: InternalFolderNames.downloadedSongs)
        print("File downloaded successfully at: \(downloadedFileUrl)")
    }

    private func removeContentFile(
        named filename: String,
        atFolder contentFolderName: String
    ) throws {
        let documentsFolder = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let file = documentsFolder.appendingPathComponent("\(contentFolderName)\(filename).mp3")
        if fileManager.fileExists(atPath: file.path) {
            try fileManager.removeItem(at: file)
        }
    }

    static func removeSoundFileIfExists(named filename: String) throws {
        let documentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileManager = FileManager.default
        let file = documentsFolder.appendingPathComponent("\(InternalFolderNames.downloadedSounds)\(filename).mp3")

        if fileManager.fileExists(atPath: file.path) {
            try fileManager.removeItem(at: file)
        }
    }


    func saveSoundFile(data: Data, id: String) throws -> URL {
        let fileURL = soundsDirectory.appendingPathComponent("\(id).mp3")
        try data.write(to: fileURL)
        return fileURL
    }

    func saveSongFile(data: Data, id: String) throws -> URL {
        let fileURL = songsDirectory.appendingPathComponent("\(id).mp3")
        try data.write(to: fileURL)
        return fileURL
    }

    func removeSoundFile(id: String) throws {
        if let fileURL = soundFileURL(id: id) {
            try fileManager.removeItem(at: fileURL)
        }
    }

    func removeSongFile(id: String) throws {
        if let fileURL = songFileURL(id: id) {
            try fileManager.removeItem(at: fileURL)
        }
    }

    func soundFileExists(id: String) throws -> Bool {
        try soundFileURL(id: id)?.checkResourceIsReachable() ?? false
    }

    func songFileExists(id: String) throws -> Bool {
        try songFileURL(id: id)?.checkResourceIsReachable() ?? false
    }

    func soundFileURL(id: String) -> URL? {
        let fileURL = soundsDirectory.appendingPathComponent("\(id).mp3")
        return fileManager.fileExists(atPath: fileURL.path) ? fileURL : nil
    }

    func songFileURL(id: String) -> URL? {
        let fileURL = songsDirectory.appendingPathComponent("\(id).mp3")
        return fileManager.fileExists(atPath: fileURL.path) ? fileURL : nil
    }
}
