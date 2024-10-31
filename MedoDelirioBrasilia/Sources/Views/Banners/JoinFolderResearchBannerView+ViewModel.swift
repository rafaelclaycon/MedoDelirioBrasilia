//
//  JoinFolderResearchBannerView+ViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 24/10/22.
//

import Foundation
import UIKit

extension JoinFolderResearchBannerView {

    @MainActor
    final class ViewModel: ObservableObject {

        @Published var state: JoinFolderResearchBannerViewState

        private let folderResearchRepository: FolderResearchRepositoryProtocol

        init(
            state: JoinFolderResearchBannerViewState,
            folderResearchRepository: FolderResearchRepositoryProtocol = FolderResearchRepository()
        ) {
            self.state = state
            self.folderResearchRepository = folderResearchRepository
        }
    }
}

// MARK: - User Actions

extension JoinFolderResearchBannerView.ViewModel {

    func onJoinResearchSelected() async {
        await sendLogs()
    }

    func onTryAgainSelected() async {
        await sendLogs()
    }
}

// MARK: - Internal Functions

extension JoinFolderResearchBannerView.ViewModel {

    private func sendLogs() async {
        state = .sendingInfo

        do {
            let folders = try LocalDatabase.shared.allFolders()
            guard !folders.isEmpty else {
                return
            }

            try await folderResearchRepository.add(
                folders: folders,
                content: folderContent(for: folders),
                installId: UIDevice.customInstallId
            )

            UserSettings().setHasJoinedFolderResearch(to: true)
            AppPersistentMemory().setHasSentFolderResearchInfo(to: true)
            state = .doneSending
        } catch {
            state = .errorSending
        }
    }

    private func folderContent(for folders: [UserFolder]) -> [UserFolderContent] {
        var contentLogs = [UserFolderContent]()
        folders.forEach { folder in
            if let contentIds = try? LocalDatabase.shared.getAllSoundIdsInsideUserFolder(withId: folder.id) {
                guard !contentIds.isEmpty else { return }
                contentIds.forEach { contentId in
                    let contentLog = UserFolderContent(userFolderId: folder.id, contentId: contentId)
                    contentLogs.append(contentLog)
                }
            }
        }
        return contentLogs
    }
}
