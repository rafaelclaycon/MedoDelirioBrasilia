//
//  PhoneSoundsContainerViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 14/04/24.
//

import SwiftUI
import Combine

@MainActor
class MainSoundContainerViewModel: ObservableObject {

    // MARK: - Published Vars

    @Published var allSounds: [Sound]?
    @Published var favorites: [Sound]?

    @Published var currentViewMode: SoundsViewMode
    @Published var soundSortOption: Int
    @Published var authorSortOption: Int

    @Published var dataLoadingDidFail: Bool = false

    // Sync
    @Published var processedUpdateNumber: Int = 0
    @Published var totalUpdateCount: Int = 0
    @Published var firstRunSyncHappened: Bool = false

    // Toast
    @Published var showToastView: Bool = false
    @Published var toastIcon: String = "checkmark"
    @Published var toastIconColor: Color = .green
    @Published var toastText: String = ""

    // MARK: - Stored Properties

    var currentSoundsListMode: Binding<SoundsListMode>

    // Sync
    private let syncManager: SyncManager
    private let syncValues: SyncValues

    // MARK: - Computed Properties

    var allSoundsPublisher: AnyPublisher<[Sound], Never> {
        $allSounds
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }

    var favoritesPublisher: AnyPublisher<[Sound], Never> {
        $favorites
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }

    // MARK: - Initializer

    init(
        currentViewMode: SoundsViewMode,
        soundSortOption: Int,
        authorSortOption: Int,
        currentSoundsListMode: Binding<SoundsListMode>,
        syncValues: SyncValues
    ) {
        self.currentViewMode = currentViewMode
        self.soundSortOption = soundSortOption
        self.authorSortOption = authorSortOption
        self.currentSoundsListMode = currentSoundsListMode

        self.syncManager = SyncManager(
            service: SyncService(
                networkRabbit: NetworkRabbit.shared,
                localDatabase: LocalDatabase.shared
            ),
            database: LocalDatabase.shared,
            logger: Logger.shared
        )
        self.syncValues = syncValues
        self.syncManager.delegate = self
    }

    // MARK: - Functions

    func reloadAllSounds() {
        do {
            let sounds = try LocalDatabase.shared.sounds(
                allowSensitive: UserSettings().getShowExplicitContent(),
                favoritesOnly: false
            )

            allSounds = sounds

            guard sounds.count > 0 else { return }
            let sortOption: SoundSortOption = SoundSortOption(rawValue: soundSortOption) ?? .dateAddedDescending
            sortAllSounds(by: sortOption)
        } catch {
            print("Erro carregando sons: \(error.localizedDescription)")
            dataLoadingDidFail = true
        }
    }

    func reloadFavorites() {
        do {
            let sounds = try LocalDatabase.shared.sounds(
                allowSensitive: UserSettings().getShowExplicitContent(),
                favoritesOnly: true
            )

            favorites = sounds

            guard sounds.count > 0 else { return }
            let sortOption: SoundSortOption = SoundSortOption(rawValue: soundSortOption) ?? .dateAddedDescending
            sortFavorites(by: sortOption)
        } catch {
            print("Erro carregando sons: \(error.localizedDescription)")
            dataLoadingDidFail = true
        }
    }

    func sortSounds(by rawSortOption: Int) {
        let sortOption = SoundSortOption(rawValue: rawSortOption) ?? .dateAddedDescending
        sortAllSounds(by: sortOption)
        sortFavorites(by: sortOption)
        UserSettings().saveMainSoundListSoundSortOption(rawSortOption)
    }
}

// MARK: - All Sounds Sorting

extension MainSoundContainerViewModel {

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
            self.allSounds?.sort(by: { $0.title.withoutDiacritics() < $1.title.withoutDiacritics() })
        }
    }

    private func sortAllSoundsByAuthorNameAscending() {
        DispatchQueue.main.async {
            self.allSounds?.sort(by: { $0.authorName?.withoutDiacritics() ?? "" < $1.authorName?.withoutDiacritics() ?? "" })
        }
    }

    private func sortAllSoundsByDateAddedDescending() {
        DispatchQueue.main.async {
            self.allSounds?.sort(by: { $0.dateAdded ?? Date() > $1.dateAdded ?? Date() })
        }
    }

    private func sortAllSoundsByDurationAscending() {
        DispatchQueue.main.async {
            self.allSounds?.sort(by: { $0.duration < $1.duration })
        }
    }

    private func sortAllSoundsByDurationDescending() {
        DispatchQueue.main.async {
            self.allSounds?.sort(by: { $0.duration > $1.duration })
        }
    }

    private func sortAllSoundsByTitleLengthAscending() {
        DispatchQueue.main.async {
            self.allSounds?.sort(by: { $0.title.count < $1.title.count })
        }
    }

    private func sortAllSoundsByTitleLengthDescending() {
        DispatchQueue.main.async {
            self.allSounds?.sort(by: { $0.title.count > $1.title.count })
        }
    }
}

// MARK: - Favorites Sorting

extension MainSoundContainerViewModel {

    private func sortFavorites(by sortOption: SoundSortOption) {
        switch sortOption {
        case .titleAscending:
            sortFavoritesByTitleAscending()
        case .authorNameAscending:
            sortFavoritesByAuthorNameAscending()
        case .dateAddedDescending:
            sortFavoritesByDateAddedDescending()
        case .shortestFirst:
            sortFavoritesByDurationAscending()
        case .longestFirst:
            sortFavoritesByDurationDescending()
        case .longestTitleFirst:
            sortFavoritesByTitleLengthDescending()
        case .shortestTitleFirst:
            sortFavoritesByTitleLengthAscending()
        }
    }

    private func sortFavoritesByTitleAscending() {
        DispatchQueue.main.async {
            self.favorites?.sort(by: { $0.title.withoutDiacritics() < $1.title.withoutDiacritics() })
        }
    }

    private func sortFavoritesByAuthorNameAscending() {
        DispatchQueue.main.async {
            self.favorites?.sort(by: { $0.authorName?.withoutDiacritics() ?? "" < $1.authorName?.withoutDiacritics() ?? "" })
        }
    }

    private func sortFavoritesByDateAddedDescending() {
        DispatchQueue.main.async {
            self.favorites?.sort(by: { $0.dateAdded ?? Date() > $1.dateAdded ?? Date() })
        }
    }

    private func sortFavoritesByDurationAscending() {
        DispatchQueue.main.async {
            self.favorites?.sort(by: { $0.duration < $1.duration })
        }
    }

    private func sortFavoritesByDurationDescending() {
        DispatchQueue.main.async {
            self.favorites?.sort(by: { $0.duration > $1.duration })
        }
    }

    private func sortFavoritesByTitleLengthAscending() {
        DispatchQueue.main.async {
            self.favorites?.sort(by: { $0.title.count < $1.title.count })
        }
    }

    private func sortFavoritesByTitleLengthDescending() {
        DispatchQueue.main.async {
            self.favorites?.sort(by: { $0.title.count > $1.title.count })
        }
    }
}

// MARK: - Data Syncing

extension MainSoundContainerViewModel: SyncManagerDelegate {

    func sync(lastAttempt: String) async {
        print("lastAttempt: \(lastAttempt)")
        guard
            CommandLine.arguments.contains("-IGNORE_2_MINUTE_SYNC_INTERVAL") ||
            lastAttempt == "" ||
            (lastAttempt.iso8601withFractionalSeconds?.twoMinutesHavePassed ?? false)
        else {
            if syncValues.syncStatus == .updating {
                syncValues.syncStatus = .done
            }

            var message = "Aguarde \(lastAttempt.minutesAndSecondsFromNow) para atualizar novamente."
            if UserSettings().getShowUpdateDateOnUI() {
                message += " \(LocalDatabase.shared.dateTimeOfLastUpdate())"
            }

            return displayToast(
                "clock.fill",
                .orange,
                toastText: message,
                displayTime: .seconds(UserSettings().getShowUpdateDateOnUI() ? 10 : 3)
            )
        }

        await syncManager.sync()

        firstRunSyncHappened = true

        var message = syncValues.syncStatus.description
        if UserSettings().getShowUpdateDateOnUI() {
            message += " \(LocalDatabase.shared.dateTimeOfLastUpdate())"
        }

        displayToast(
            syncValues.syncStatus == .done ? "checkmark" : "exclamationmark.triangle.fill",
            syncValues.syncStatus == .done ? .green : .orange,
            toastText: message,
            displayTime: .seconds(UserSettings().getShowUpdateDateOnUI() ? 10 : 3)
        )
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
                reloadAllSounds()
            }
        }
        print(status)
    }
}

// MARK: - Toast

extension MainSoundContainerViewModel {

    func displayToast(
        _ toastIcon: String,
        _ toastIconColor: Color,
        toastText: String,
        displayTime: DispatchTimeInterval,
        completion: (() -> Void)? = nil
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
            withAnimation {
                self.toastIcon = toastIcon
                self.toastIconColor = toastIconColor
                self.toastText = toastText
                self.showToastView = true
            }
            TapticFeedback.success()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + displayTime) {
            withAnimation {
                self.showToastView = false
                completion?()
            }
        }
    }
}
