//
//  FolderResearchHelper.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 30/10/24.
//

import Foundation
import CryptoKit

final class FolderResearchHelper {

    private let userSettings: UserSettingsProtocol
    private let appMemory: AppPersistentMemory
    private let localDatabase: LocalDatabaseProtocol

    init(
        userSettings: UserSettingsProtocol,
        appMemory: AppPersistentMemory,
        localDatabase: LocalDatabaseProtocol
    ) {
        self.userSettings = userSettings
        self.appMemory = appMemory
        self.localDatabase = localDatabase
    }

    func hash(_ string: String) -> String {
        let inputData = Data(string.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }

    func changes() -> (UserFolder, UserFolderContent)? {
        guard userSettings.getHasJoinedFolderResearch() else { return nil }
        return (.init(symbol: "", name: "", backgroundColor: ""), .init(userFolderId: "", contentId: ""))
    }
}
