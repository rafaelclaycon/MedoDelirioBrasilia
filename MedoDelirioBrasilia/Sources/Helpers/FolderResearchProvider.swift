//
//  FolderResearchProvider.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 30/10/24.
//

import Foundation
import CryptoKit

final class FolderResearchProvider {

    private let userSettings: UserSettingsProtocol
    private let appMemory: AppPersistentMemoryProtocol
    private let localDatabase: LocalDatabaseProtocol
    private let repository: FolderResearchRepositoryProtocol

    init(
        userSettings: UserSettingsProtocol,
        appMemory: AppPersistentMemoryProtocol,
        localDatabase: LocalDatabaseProtocol,
        repository: FolderResearchRepositoryProtocol
    ) {
        self.userSettings = userSettings
        self.appMemory = appMemory
        self.localDatabase = localDatabase
        self.repository = repository
    }

    static func hash(_ string: String) -> String {
        let inputData = Data(string.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }

    /// Returns all User Folders and Contents for use both inside the Provider and outside.
    /// Doesn't do any enrollment checks because outside the enrollment could be set later on.
    func all() throws -> (
        folders: [UserFolder],
        content: [UserFolderContent]?
    )? {
        let folders = try localDatabase.allFolders()
        guard !folders.isEmpty else { return nil }
        return (folders: folders, content: folderContent(for: folders)) 
    }

    /// Returns all User Folders and Contents that have changed since the last time this info was sent.
    /// This last part is verified by saving a hash of folders names + content IDs.
    func changes() throws -> (
        folders: [UserFolder],
        content: [UserFolderContent]?
    )? {
        guard userSettings.getHasJoinedFolderResearch() else { return nil }
        guard appMemory.getHasSentFolderResearchInfo() else {
            return try all()
        }

        guard let changedFolderIds = try changedFolderIds() else {
            if let deleted = try deletedFolders() {
                return (folders: deleted, content: nil)
            }
            return nil
        }
        var folders = try localDatabase.folders(withIds: changedFolderIds)
        var contents = [UserFolderContent]()
        try folders.forEach { folder in
            let folderContents = try localDatabase.contentsInside(userFolder: folder.id)
            contents.append(contentsOf: folderContents)
        }

        if let deleted = try deletedFolders() {
            folders.append(contentsOf: deleted)
        }

        return (folders: folders, content: contents)
    }

    func sendChanges() async throws {
        guard userSettings.getHasJoinedFolderResearch() else { return }

        guard
            let changes = try changes(),
            !changes.folders.isEmpty
        else {
            appMemory.setHasSentFolderResearchInfo(to: true)
            appMemory.lastFolderResearchSyncDateTime(.now)
            return
        }

        try await repository.add(
            folders: changes.folders,
            content: changes.content,
            installId: appMemory.customInstallId
        )

        try saveCurrentHashesToAppMemory()

        appMemory.setHasSentFolderResearchInfo(to: true)
        appMemory.lastFolderResearchSyncDateTime(.now)
    }
}

// MARK: - Internal Functions

extension FolderResearchProvider {

    private func folderContent(for folders: [UserFolder]) -> [UserFolderContent]? {
        guard !folders.isEmpty else { return nil }
        var contentLogs = [UserFolderContent]()
        folders.forEach { folder in
            if let contentIds = try? localDatabase.soundIdsInside(userFolder: folder.id) {
                guard !contentIds.isEmpty else { return }
                contentIds.forEach { contentId in
                    let contentLog = UserFolderContent(userFolderId: folder.id, contentId: contentId)
                    contentLogs.append(contentLog)
                }
            }
        }
        return contentLogs
    }

    private func hashOfCurrentContents() throws -> [String: String] {
        return try localDatabase.folderHashes()
    }

    private func changedFolderIds() throws -> [String]? {
        let latestHashes = try hashOfCurrentContents()
        guard
            let storedHashes = appMemory.folderResearchHashes()
        else {
            return latestHashes.keys.map { $0 }
        }

        var changedFolders = [String]()
        for (id, latestHash) in latestHashes {
            if storedHashes[id] != latestHash {
                // If there's a mismatch or the hash doesn't exist in UserDefaults, mark as changed
                changedFolders.append(id)
            }
        }
        return changedFolders.isEmpty ? nil : changedFolders
    }

    private func deletedFolders() throws -> [UserFolder]? {
        let latestHashes = try hashOfCurrentContents()
        guard
            let storedHashes = appMemory.folderResearchHashes()
        else {
            return nil
        }

        var deletedFolders = [String]()
        storedHashes.keys.forEach { id in
            if !latestHashes.contains(where: { $0.key == id }) {
                deletedFolders.append(id)
            }
        }

        guard !deletedFolders.isEmpty else { return nil }
        return deletedFolders.map {
            UserFolder(id: $0, symbol: "", name: "[Deleted]", backgroundColor: "")
        }
    }

    private func saveCurrentHashesToAppMemory() throws {
        let folders = try localDatabase.allFolders()
        let hashes: [String: String] = Dictionary(uniqueKeysWithValues: folders.map { ($0.id, $0.changeHash ?? "") })
        appMemory.folderResearchHashes(hashes)
    }
}
