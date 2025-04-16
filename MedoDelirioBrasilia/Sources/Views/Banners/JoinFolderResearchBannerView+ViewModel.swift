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
        UserSettings().setHasJoinedFolderResearch(to: true)
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
            let provider = FolderResearchProvider(
                userSettings: UserSettings(),
                appMemory: AppPersistentMemory(),
                localDatabase: LocalDatabase(),
                repository: FolderResearchRepository()
            )

            try await provider.sendChanges()

            state = .doneSending
        } catch {
            Task {
                await AnalyticsService().send(
                    originatingScreen: "JoinFolderResearchBannerView",
                    action: "issueFetchingAll(\(error.localizedDescription))"
                )
            }
            state = .errorSending
        }
    }
}
