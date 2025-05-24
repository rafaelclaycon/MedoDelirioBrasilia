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

    // MARK: - Stored Properties

    public var currentContentListMode: Binding<ContentGridMode>
    public var toast: Binding<Toast?>
    public var floatingOptions: Binding<FloatingContentOptions?>
    private let contentRepository: ContentRepositoryProtocol
    private let analyticsService: AnalyticsServiceProtocol
    public let contentUpdateService: ContentUpdateServiceProtocol

    // Content Update
    private let syncValues: SyncValues
    public var displayLongUpdateBanner: Bool = false
    public var dismissedLongUpdateBanner: Bool = false

    // MARK: - Initializer

    init(
        currentViewMode: ContentModeOption,
        contentSortOption: Int,
        authorSortOption: Int,
        currentContentListMode: Binding<ContentGridMode>,
        toast: Binding<Toast?>,
        floatingOptions: Binding<FloatingContentOptions?>,
        contentUpdateService: ContentUpdateServiceProtocol,
        syncValues: SyncValues,
        contentRepository: ContentRepositoryProtocol,
        analyticsService: AnalyticsServiceProtocol
    ) {
        self.currentViewMode = currentViewMode
        self.contentSortOption = contentSortOption
        self.authorSortOption = authorSortOption
        self.currentContentListMode = currentContentListMode
        self.toast = toast
        self.floatingOptions = floatingOptions
        self.contentUpdateService = contentUpdateService
        self.syncValues = syncValues
        self.contentRepository = contentRepository
        self.analyticsService = analyticsService
    }
}

// MARK: - User Actions

extension MainContentViewModel {

    public func onViewDidAppear() async {
        print("MAIN CONTENT VIEW - ON APPEAR")
        updateDisplayLongUpdateBanner()
        loadContent()
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

    public func onAllowFirstContentUpdateSelected() async {
        AppPersistentMemory().hasAllowedContentUpdate(true)
        let hadAnyUpdates = await contentUpdateService.update()
        loadContent(clearCache: hadAnyUpdates)
    }

    public func onDismissFirstContentUpdateSelected() {
        dismissedLongUpdateBanner = true
        updateDisplayLongUpdateBanner()
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

    private func sync(lastAttempt: String) async -> Bool {
        print("lastAttempt: \(lastAttempt)")

        // Logic for pulling down - keep here
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

        let hadAnyUpdates = await contentUpdateService.update()

        let message = syncValues.syncStatus.description
        toast.wrappedValue = Toast(message: message, type: syncValues.syncStatus == .done ? .success : .warning)

        return hadAnyUpdates
    }

    /// Warm open means the app was reopened before it left memory.
    private func warmOpenSync() async -> Bool {
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

    private func updateDisplayLongUpdateBanner() {
        guard !dismissedLongUpdateBanner else { return displayLongUpdateBanner = false }
        guard AppPersistentMemory().hasAllowedContentUpdate() else { return displayLongUpdateBanner = true }
        let moreThan10Updates = contentUpdateService.totalUpdateCount >= 10
        let hasNotReached100Percent = contentUpdateService.currentUpdate != contentUpdateService.totalUpdateCount
        displayLongUpdateBanner = moreThan10Updates && hasNotReached100Percent
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
