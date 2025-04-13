//
//  PhoneSoundsContainerViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 14/04/24.
//

import SwiftUI
import Combine

@MainActor
class MainContentViewModel: ObservableObject {

    // MARK: - Published Vars

    @Published var forDisplay: [AnyEquatableMedoContent]?

    @Published var currentViewMode: TopSelectorOption
    @Published var soundSortOption: Int
    @Published var authorSortOption: Int

    @Published var dataLoadingDidFail: Bool = false

    // Sync
    @Published var processedUpdateNumber: Int = 0
    @Published var totalUpdateCount: Int = 0
    @Published var firstRunSyncHappened: Bool = false

    // MARK: - Stored Properties

    public var currentContentListMode: Binding<ContentListMode>
    public var toast: Binding<Toast?>
    private var allContent = [AnyEquatableMedoContent]()

    // Sync
    private let syncManager: SyncManager
    private let syncValues: SyncValues
    private let isAllowedToSync: Bool

    // MARK: - Computed Properties

    var allContentPublisher: AnyPublisher<[AnyEquatableMedoContent], Never> {
        $forDisplay
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }

    // MARK: - Initializer

    init(
        currentViewMode: TopSelectorOption,
        soundSortOption: Int,
        authorSortOption: Int,
        currentContentListMode: Binding<ContentListMode>,
        toast: Binding<Toast?>,
        syncValues: SyncValues,
        isAllowedToSync: Bool = true
    ) {
        self.currentViewMode = currentViewMode
        self.soundSortOption = soundSortOption
        self.authorSortOption = authorSortOption
        self.currentContentListMode = currentContentListMode
        self.toast = toast

        self.syncManager = SyncManager(
            service: SyncService(
                networkRabbit: NetworkRabbit.shared,
                localDatabase: LocalDatabase.shared
            ),
            database: LocalDatabase.shared,
            logger: Logger.shared
        )
        self.syncValues = syncValues
        self.isAllowedToSync = isAllowedToSync
        self.syncManager.delegate = self
    }
}

// MARK: - User Actions

extension MainContentViewModel {

    public func onViewDidAppear() {
        print("MAIN SOUND CONTAINER - ON APPEAR")

        if !firstRunSyncHappened {
            Task {
                print("WILL START SYNCING")
                await sync(lastAttempt: AppPersistentMemory().getLastUpdateAttempt())
                print("DID FINISH SYNCING")
            }
        }

        loadContent()
        //loadFavorites()
    }

    public func onSelectedViewModeChanged(favorites: Set<String>) {
        if currentViewMode == .all {
            forDisplay = allContent
        } else if currentViewMode == .favorites {
            forDisplay = allContent.filter { favorites.contains($0.id) }
        } else if currentViewMode == .songs {
            forDisplay = allContent.filter { $0.type == .song }
        }
        sortSounds(by: soundSortOption)
    }

    public func onSoundSortOptionChanged() {
        sortSounds(by: soundSortOption)
    }

    public func onExplicitContentSettingChanged() {
        loadContent()
    }

    public func onSyncRequested() async {
        await sync(lastAttempt: AppPersistentMemory().getLastUpdateAttempt())
    }

    public func onScenePhaseChanged(newPhase: ScenePhase) async {
        if newPhase == .active {
            await warmOpenSync()
            print("DID FINISH WARM OPEN SYNC")
        }
    }
}

// MARK: - Internal Functions

extension MainContentViewModel {

    private func loadContent() {
        do {
            let sounds: [AnyEquatableMedoContent] = try LocalDatabase.shared.sounds(
                allowSensitive: UserSettings().getShowExplicitContent()
            ).map { AnyEquatableMedoContent($0) }
            let songs: [AnyEquatableMedoContent] = try LocalDatabase.shared.songs(
                allowSensitive: UserSettings().getShowExplicitContent()
            ).map { AnyEquatableMedoContent($0) }

            allContent = sounds + songs
            forDisplay = allContent

            guard sounds.count > 0 else { return }
            let sortOption: SoundSortOption = SoundSortOption(rawValue: soundSortOption) ?? .dateAddedDescending
            sortAllSounds(by: sortOption)
        } catch {
            print("Erro carregando sons: \(error.localizedDescription)")
            dataLoadingDidFail = true
        }
    }

    private func sortSounds(by rawSortOption: Int) {
        let sortOption = SoundSortOption(rawValue: rawSortOption) ?? .dateAddedDescending
        sortAllSounds(by: sortOption)
        UserSettings().saveMainSoundListSoundSortOption(rawSortOption)
    }
}

// MARK: - Sorting

extension MainContentViewModel {

    private func sortAllSounds(by sortOption: SoundSortOption) {
        switch sortOption {
        case .titleAscending:
            sortAllSoundsByTitleAscending()
        case .authorNameAscending:
            sortAllSoundsByAuthorNameAscending()
        case .dateAddedDescending:
            sortAllSoundsByDateAddedDescending()
        case .shortestFirst:
            sortAllSoundsByDurationAscending()
        case .longestFirst:
            sortAllSoundsByDurationDescending()
        case .longestTitleFirst:
            sortAllSoundsByTitleLengthDescending()
        case .shortestTitleFirst:
            sortAllSoundsByTitleLengthAscending()
        }
    }

    private func sortAllSoundsByTitleAscending() {
        DispatchQueue.main.async {
            self.forDisplay?.sort(by: { $0.title.withoutDiacritics() < $1.title.withoutDiacritics() })
        }
    }

    private func sortAllSoundsByAuthorNameAscending() {
        DispatchQueue.main.async {
            self.forDisplay?.sort(by: { $0.subtitle.withoutDiacritics() < $1.subtitle.withoutDiacritics() })
        }
    }

    private func sortAllSoundsByDateAddedDescending() {
        DispatchQueue.main.async {
            self.forDisplay?.sort(by: { $0.dateAdded ?? Date() > $1.dateAdded ?? Date() })
        }
    }

    private func sortAllSoundsByDurationAscending() {
        DispatchQueue.main.async {
            self.forDisplay?.sort(by: { $0.duration < $1.duration })
        }
    }

    private func sortAllSoundsByDurationDescending() {
        DispatchQueue.main.async {
            self.forDisplay?.sort(by: { $0.duration > $1.duration })
        }
    }

    private func sortAllSoundsByTitleLengthAscending() {
        DispatchQueue.main.async {
            self.forDisplay?.sort(by: { $0.title.count < $1.title.count })
        }
    }

    private func sortAllSoundsByTitleLengthDescending() {
        DispatchQueue.main.async {
            self.forDisplay?.sort(by: { $0.title.count > $1.title.count })
        }
    }
}

// MARK: - Data Syncing

extension MainContentViewModel: SyncManagerDelegate {

    private func sync(lastAttempt: String) async {
        print("lastAttempt: \(lastAttempt)")

        guard isAllowedToSync else { return }

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
            return
        }

        await syncManager.sync()

        firstRunSyncHappened = true

        let message = syncValues.syncStatus.description

        toast.wrappedValue = Toast(message: message, type: syncValues.syncStatus == .done ? .success : .warning)
    }

    // Warm open means the app was reopened before it left memory.
    private func warmOpenSync() async {
        guard isAllowedToSync else { return }

        let lastUpdateAttempt = AppPersistentMemory().getLastUpdateAttempt()
        print("lastUpdateAttempt: \(lastUpdateAttempt)")
        guard
            syncValues.syncStatus != .updating,
            let date = lastUpdateAttempt.iso8601withFractionalSeconds,
            date.minutesPassed(60)
        else { return }

        print("WILL WARM OPEN SYNC")
        await sync(lastAttempt: lastUpdateAttempt)
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
