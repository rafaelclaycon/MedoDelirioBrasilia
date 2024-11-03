//
//  FolderResearchSettingsView+ViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 02/11/24.
//

import UIKit

extension FolderResearchSettingsView {

    @MainActor
    final class ViewModel: ObservableObject {

        @Published var state: FolderResearchSettingsViewState = .notEnrolled

        @Published var hasJoinedFolderResearch: Bool = false
        @Published var lastSendDate: String = ""
        @Published var didFinishLoadingInitialState = false

        private let folderResearchRepository: FolderResearchRepositoryProtocol

        init(
            folderResearchRepository: FolderResearchRepositoryProtocol = FolderResearchRepository()
        ) {
            self.folderResearchRepository = folderResearchRepository
        }
    }
}

// MARK: - User Actions

extension FolderResearchSettingsView.ViewModel {

    func onViewLoaded() {
        let isEnrolled = UserSettings().getHasJoinedFolderResearch()
        self.state = isEnrolled ? .enrolled : .notEnrolled
        self.hasJoinedFolderResearch = isEnrolled
        updateLastSyncDate()
        didFinishLoadingInitialState = true
    }

    func onEnrollOptionChanged(_ enroll: Bool) async {
        guard didFinishLoadingInitialState else { return }
        if enroll {
            print("DID CALL SEND LOGS")
            UserSettings().setHasJoinedFolderResearch(to: true)
            await sendLogs()
            updateLastSyncDate()
        } else {
            UserSettings().setHasJoinedFolderResearch(to: false)
            state = .notEnrolled
        }
    }
}

// MARK: - Internal Functions

extension FolderResearchSettingsView.ViewModel {

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

            state = .enrolled
        } catch {
            Analytics().send(
                originatingScreen: "FolderResearchSettingsView",
                action: "issueSyncingChanges(\(error.localizedDescription))"
            )
            state = .errorSending
        }
    }

    private func updateLastSyncDate() {
        guard let date = AppPersistentMemory().lastFolderResearchSyncDateTime() else {
            lastSendDate = "Indisponível"
            return
        }
        lastSendDate = date.formattedDayMonthYearHoursMinutes()
    }
}
