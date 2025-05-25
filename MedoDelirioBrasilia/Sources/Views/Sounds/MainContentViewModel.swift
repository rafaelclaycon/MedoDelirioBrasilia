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
    private var contentUpdateService: ContentUpdateServiceProtocol

    // Content Update
    private let syncValues: SyncValues
    var displayLongUpdateBanner: Bool = false
    var dismissedLongUpdateBanner: Bool = false
    var processedUpdateNumber: Int = 0
    var totalUpdateCount: Int = 0

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

        self.contentUpdateService.delegate = self
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

    public func onContentUpdateRequested() async {
        await updateContent(lastAttempt: AppPersistentMemory().getLastUpdateAttempt())
    }

    public func onScenePhaseChanged(newPhase: ScenePhase) async {
        if newPhase == .active {
            await warmOpenContentUpdate()
        }
    }

    public func onFavoritesChanged() {
        loadContent()
    }

    public func onAllowFirstContentUpdateSelected() async {
        AppPersistentMemory().hasAllowedContentUpdate(true)
        await contentUpdateService.update()
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

    private func updateContent(lastAttempt: String) async {
        guard AppPersistentMemory().hasAllowedContentUpdate() else { return }

        print("lastAttempt: \(lastAttempt)")

        // Logic for pulling down - keep here
        guard
            CommandLine.arguments.contains("-IGNORE_CONTENT_UPDATE_WAIT") ||
            lastAttempt == "" ||
            (lastAttempt.iso8601withFractionalSeconds?.minutesPassed(1) ?? false)
        else {
            if syncValues.syncStatus == .updating {
                syncValues.syncStatus = .done
            }

            let message = String(format: Shared.Sync.waitMessage, lastAttempt.timeUntil(addingMinutes: 1))

            toast.wrappedValue = Toast(message: message, type: .wait)
            return
        }

        await contentUpdateService.update()

        let message = syncValues.syncStatus.description
        toast.wrappedValue = Toast(message: message, type: syncValues.syncStatus == .done ? .success : .warning)
    }

    /// Warm open means the app was reopened before it left memory.
    private func warmOpenContentUpdate() async {
        guard AppPersistentMemory().hasAllowedContentUpdate() else { return }

        let lastUpdateAttempt = AppPersistentMemory().getLastUpdateAttempt()
        print("lastUpdateAttempt: \(lastUpdateAttempt)")
        guard
            syncValues.syncStatus != .updating,
            let date = lastUpdateAttempt.iso8601withFractionalSeconds,
            date.minutesPassed(60)
        else { return }

        print("WILL WARM OPEN CONTENT UPDATE")
        await updateContent(lastAttempt: lastUpdateAttempt)
        print("DID FINISH WARM OPEN CONTENT UPDATE")
    }

    private func updateDisplayLongUpdateBanner() {
        guard !dismissedLongUpdateBanner else { return displayLongUpdateBanner = false }
        guard AppPersistentMemory().hasAllowedContentUpdate() else { return displayLongUpdateBanner = true }
        displayLongUpdateBanner = totalUpdateCount >= 10 && processedUpdateNumber != totalUpdateCount
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

// MARK: - Content Update

extension MainContentViewModel: ContentUpdateServiceDelegate {

    nonisolated func set(totalUpdateCount: Int) {
        Task { @MainActor in
            self.totalUpdateCount = totalUpdateCount
            print("RAFA - totalUpdateCount: \(totalUpdateCount)")
        }
    }

    nonisolated func didProcessUpdate(number: Int) {
        Task { @MainActor in
            self.processedUpdateNumber = number
            print("RAFA - processedUpdateNumber: \(number)")
            updateDisplayLongUpdateBanner()
        }
    }

    nonisolated func update(status: ContentUpdateStatus, contentChanged: Bool) {
        Task { @MainActor in
            self.syncValues.syncStatus = status
            print("RAFA - new status: \(status.description)")

            if contentChanged {
                loadContent(clearCache: true)
            }
            print(status)
            if status == .done {
                displayLongUpdateBanner = false
            } else {
                updateDisplayLongUpdateBanner()
            }
        }
    }
}
