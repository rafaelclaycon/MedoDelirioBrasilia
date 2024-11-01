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

    init(
        userSettings: UserSettingsProtocol,
        appMemory: AppPersistentMemoryProtocol,
        localDatabase: LocalDatabaseProtocol
    ) {
        self.userSettings = userSettings
        self.appMemory = appMemory
        self.localDatabase = localDatabase
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

        // Here only stuff that has changed
        //let folders.map { $0.id }.joined()
        return (folders: [.init(symbol: "", name: "", backgroundColor: "")], content: nil)
    }
}

// MARK: - Internal Functions

extension FolderResearchProvider {

    func hash(_ string: String) -> String {
        let inputData = Data(string.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }

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

    private func hashOfCurrentContents() {
        
    }
}
