//
//  PhoneSoundsContainerViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 14/04/24.
//

import SwiftUI

@MainActor
@Observable
class MainContentViewModel {

    var state: LoadingState<[AnyEquatableMedoContent]> = .loading

    var currentViewMode: ContentModeOption
    var contentSortOption: Int
    var authorSortOption: Int

    // Sync
    var processedUpdateNumber: Int = 0
    var totalUpdateCount: Int = 0
    var firstRunSyncHappened: Bool = false

    // MARK: - Stored Properties

    public var currentContentListMode: Binding<ContentGridMode>
    public var toast: Binding<Toast?>
    public var floatingOptions: Binding<FloatingContentOptions?>
    private let contentRepository: ContentRepositoryProtocol
    private let analyticsService: AnalyticsServiceProtocol

    // Sync
    private let syncManager: SyncManager
    private let syncValues: SyncValues
    private let isAllowedToSync: Bool

    // MARK: - Initializer

    init(
        currentViewMode: ContentModeOption,
        contentSortOption: Int,
        authorSortOption: Int,
        currentContentListMode: Binding<ContentGridMode>,
        toast: Binding<Toast?>,
        floatingOptions: Binding<FloatingContentOptions?>,
        syncValues: SyncValues,
        isAllowedToSync: Bool = true,
        contentRepository: ContentRepositoryProtocol,
        analyticsService: AnalyticsServiceProtocol
    ) {
        self.currentViewMode = currentViewMode
        self.contentSortOption = contentSortOption
        self.authorSortOption = authorSortOption
        self.currentContentListMode = currentContentListMode
        self.toast = toast
        self.floatingOptions = floatingOptions

        self.syncManager = SyncManager(
            service: SyncService(
                apiClient: APIClient.shared,
                localDatabase: LocalDatabase.shared
            ),
            database: LocalDatabase.shared,
            logger: Logger.shared
        )
        self.syncValues = syncValues
        self.contentRepository = contentRepository
        self.analyticsService = analyticsService
        self.isAllowedToSync = isAllowedToSync
        self.syncManager.delegate = self
    }
}

// MARK: - User Actions

extension MainContentViewModel {

    public func onViewDidAppear() async {
        print("MAIN CONTENT VIEW - ON APPEAR")

        var hadAnyUpdates: Bool = false

        if !firstRunSyncHappened {
            print("WILL START SYNCING")
            hadAnyUpdates = await sync(lastAttempt: AppPersistentMemory().getLastUpdateAttempt())
            print("DID FINISH SYNCING")
        }

        loadContent(clearCache: hadAnyUpdates)
    }

    public func onSelectedViewModeChanged() async {
        loadContent()
        await fireAnalytics()
    }

    public func onContentSortOptionChanged() {
        loadContent()
    }

    public func onExplicitContentSettingChanged() {
        loadContent()
    }

    public func onSyncRequested() async {
        let hadAnyUpdates = await sync(lastAttempt: AppPersistentMemory().getLastUpdateAttempt())
        loadContent(clearCache: hadAnyUpdates)
    }

    public func onScenePhaseChanged(newPhase: ScenePhase) async {
        if newPhase == .active {
            let hadAnyUpdates = await warmOpenSync()
            loadContent(clearCache: hadAnyUpdates)
            print("DID FINISH WARM OPEN SYNC")
        }
    }

    public func onFavoritesChanged() {
        loadContent()
    }
}

// MARK: - Internal Functions

extension MainContentViewModel {

    private func loadContent(clearCache: Bool = false) {
        state = .loading

        if clearCache {
            contentRepository.clearCache()
        }

        do {
            let allowSensitive = UserSettings().getShowExplicitContent()
            let sort = SoundSortOption(rawValue: contentSortOption) ?? .dateAddedDescending
            if currentViewMode == .all {
                state = .loaded(try contentRepository.allContent(allowSensitive, sort))
            } else if currentViewMode == .favorites {
                state = .loaded(try contentRepository.favorites(allowSensitive, sort))
            } else if currentViewMode == .songs {
                state = .loaded(try contentRepository.songs(allowSensitive, sort))
            }
        } catch {
            state = .error(error.localizedDescription)
            debugPrint(error)
        }
    }

    private func fireAnalytics() async {
        let screen = "MainContentView"
        if currentViewMode == .favorites {
            await analyticsService.send(originatingScreen: screen, action: "didViewFavoritesTab")
        } else if currentViewMode == .songs {
            await analyticsService.send(originatingScreen: screen, action: "didViewSongsTab")
        } else if currentViewMode == .folders {
            await analyticsService.send(originatingScreen: screen, action: "didViewFoldersTab")
        } else if currentViewMode == .authors {
            await analyticsService.send(originatingScreen: screen, action: "didViewAuthorsTab")
        }
    }
}

// MARK: - Data Syncing

extension MainContentViewModel: SyncManagerDelegate {

    private func sync(lastAttempt: String) async -> Bool {
        print("lastAttempt: \(lastAttempt)")

        guard isAllowedToSync else { return false }

        guard
            CommandLine.arguments.contains("-IGNORE_SYNC_WAIT") ||
            lastAttempt == "" ||
            (lastAttempt.iso8601withFractionalSeconds?.minutesPassed(1) ?? false)
        else {
            if syncValues.syncStatus == .updating {
                syncValues.syncStatus = .done
            }

            let message = String(format: Shared.Sync.waitMessage, lastAttempt.timeUntil(addingMinutes: 1))

            toast.wrappedValue = Toast(message: message, type: .wait)
            return false
        }

        let hadAnyUpdates = await syncManager.sync()

        firstRunSyncHappened = true

        let message = syncValues.syncStatus.description
        toast.wrappedValue = Toast(message: message, type: syncValues.syncStatus == .done ? .success : .warning)

        return hadAnyUpdates
    }

    /// Warm open means the app was reopened before it left memory.
    private func warmOpenSync() async -> Bool {
        guard isAllowedToSync else { return false }

        let lastUpdateAttempt = AppPersistentMemory().getLastUpdateAttempt()
        print("lastUpdateAttempt: \(lastUpdateAttempt)")
        guard
            syncValues.syncStatus != .updating,
            let date = lastUpdateAttempt.iso8601withFractionalSeconds,
            date.minutesPassed(60)
        else { return false }

        print("WILL WARM OPEN SYNC")
        return await sync(lastAttempt: lastUpdateAttempt)
    }

    nonisolated func set(totalUpdateCount: Int) {
        Task { @MainActor in
            self.totalUpdateCount = totalUpdateCount
        }
    }

    nonisolated func didProcessUpdate(number: Int) {
        Task { @MainActor in
            processedUpdateNumber = number
        }
    }

    nonisolated func didFinishUpdating(
        status: SyncUIStatus,
        updateSoundList: Bool
    ) {
        Task { @MainActor in
            self.syncValues.syncStatus = status

            if updateSoundList {
                loadContent()
            }
        }
        print(status)
    }
}
