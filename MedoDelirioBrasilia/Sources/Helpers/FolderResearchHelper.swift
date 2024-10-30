//
//  FolderResearchHelper.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 25/10/22.
//

import UIKit

protocol FolderResearchRepositoryProtocol {

    func add(
        folders: [UserFolder],
        content: [UserFolderContent],
        installId: String
    ) async throws
}

class FolderResearchRepository: FolderResearchRepositoryProtocol {

    private let apiClient: NetworkRabbit

    // MARK: - Initializer

    init(
        apiClient: NetworkRabbit = NetworkRabbit(serverPath: APIConfig.apiURL)
    ) {
        self.apiClient = apiClient
    }

    func add(
        folders: [UserFolder],
        content: [UserFolderContent],
        installId: String
    ) async throws {
        var folderLogs = [UserFolderLog]()
        folders.forEach { folder in
            folderLogs.append(
                UserFolderLog(
                    installId: installId,
                    folderId: folder.id,
                    folderSymbol: folder.symbol,
                    folderName: folder.name,
                    backgroundColor: folder.backgroundColor,
                    logDateTime: Date.now.iso8601withFractionalSeconds
                )
            )
        }

        var contentLogs = [UserFolderContentLog]()
        content.forEach { sound in
            guard let folderLog = folderLogs.first(where: { $0.folderId == sound.userFolderId }) else { return }
            contentLogs.append(.init(userFolderLogId: folderLog.id, contentId: sound.contentId))
        }

        let foldersUrl = URL(string: apiClient.serverPath + "v1/user-folder-logs")!
        try await apiClient.post(to: foldersUrl, body: folderLogs)

        let soundsUrl = URL(string: apiClient.serverPath + "v1/user-folder-content-logs")!
        try await apiClient.post(to: soundsUrl, body: contentLogs)
    }
}
