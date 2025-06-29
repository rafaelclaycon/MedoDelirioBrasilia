//
//  PhoneSoundsContainerViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 14/04/24.
//

import SwiftUI

@MainActor
@Observable
final class MainContentViewModel {

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

    private var isRunningUnitTests: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }

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

        self.setupObservers()
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
        await updateContent(lastAttempt: AppPersistentMemory.shared.getLastUpdateAttempt())
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
        AppPersistentMemory.shared.hasAllowedContentUpdate(true)
        await contentUpdateService.update()
    }

    public func onDismissFirstContentUpdateSelected() {
        dismissedLongUpdateBanner = true
        updateDisplayLongUpdateBanner()
    }
}

// MARK: - Internal Functions

extension MainContentViewModel {

    private func setupObservers() {
        print("RAFA - Setting up observers on instance: \(ObjectIdentifier(self))")

        Task { @MainActor in
            do {
                for try await progressUpdate in contentUpdateService.progressUpdates {
                    print("RAFA - Received progress update on instance: \(ObjectIdentifier(self))")
                    self.processedUpdateNumber = progressUpdate.processed
                    self.totalUpdateCount = progressUpdate.total
                    print("RAFA - Progress Update - processed: \(progressUpdate.processed), total: \(progressUpdate.total)")
                    self.updateDisplayLongUpdateBanner()
                    print("RAFA - displayLongUpdateBanner AFTER update: \(self.displayLongUpdateBanner)")
                }
            } catch {
                print("Error observing progress updates: \(error)")
            }
        }
        
        // Start observing status updates  
        Task { @MainActor in
            do {
                for try await statusUpdate in contentUpdateService.statusUpdates {
                    print("RAFA - Received status update on instance: \(ObjectIdentifier(self))")
                    self.syncValues.syncStatus = statusUpdate.status
                    print("RAFA - Status Update: \(statusUpdate.status.description)")
                    
                    if statusUpdate.contentChanged {
                        self.loadContent(clearCache: true)
                    }
                    
                    if statusUpdate.status == .done {
                        self.displayLongUpdateBanner = false
                    } else {
                        self.updateDisplayLongUpdateBanner()
                    }
                }
            } catch {
                print("Error observing status updates: \(error)")
            }
        }
    }

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
        guard AppPersistentMemory.shared.hasAllowedContentUpdate() else { return }

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
        guard AppPersistentMemory.shared.hasAllowedContentUpdate() else { return }
        guard !isRunningUnitTests else { return }

        let lastUpdateAttempt = AppPersistentMemory.shared.getLastUpdateAttempt()
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
        guard AppPersistentMemory.shared.hasAllowedContentUpdate() else { return displayLongUpdateBanner = true }
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
