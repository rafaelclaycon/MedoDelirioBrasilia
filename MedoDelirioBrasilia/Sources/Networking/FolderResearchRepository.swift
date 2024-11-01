//
//  FolderResearchRepository.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 30/10/24.
//

import UIKit

protocol FolderResearchRepositoryProtocol {

    func add(
        folders: [UserFolder],
        content: [UserFolderContent]?,
        installId: String
    ) async throws
}

final class FolderResearchRepository: FolderResearchRepositoryProtocol {

    private let apiClient: NetworkRabbit

    // MARK: - Initializer

    init(
        apiClient: NetworkRabbit = NetworkRabbit(serverPath: APIConfig.apiURL)
    ) {
        self.apiClient = apiClient
    }

    func add(
        folders: [UserFolder],
        content: [UserFolderContent]?,
        installId: String
    ) async throws {
        let folderLogs = folders.map { folder in
            UserFolderLog(
                installId: installId,
                folderId: folder.id,
                folderSymbol: folder.symbol,
                folderName: folder.name,
                backgroundColor: folder.backgroundColor,
                logDateTime: Date.now.iso8601withFractionalSeconds
            )
        }

        let foldersUrl = URL(string: apiClient.serverPath + "v1/user-folder-logs")!
        try await apiClient.post(to: foldersUrl, body: folderLogs)

        guard let content else { return }

        let contentLogs: [UserFolderContentLog] = content.compactMap { sound in
            guard let folderLog = folderLogs.first(where: { $0.folderId == sound.userFolderId }) else { return nil }
            return UserFolderContentLog(userFolderLogId: folderLog.id, contentId: sound.contentId)
        }

        let soundsUrl = URL(string: apiClient.serverPath + "v1/user-folder-content-logs")!
        try await apiClient.post(to: soundsUrl, body: contentLogs)
    }
}
