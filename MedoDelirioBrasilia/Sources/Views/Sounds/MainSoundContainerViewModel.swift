//
//  PhoneSoundsContainerViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 14/04/24.
//

import SwiftUI
import Combine

class MainSoundContainerViewModel: ObservableObject {

    // MARK: - Published Vars

    @Published var allSounds: [Sound] = []
    @Published var favorites: [Sound] = []

    @Published var currentViewMode: SoundsViewMode
    @Published var soundSortOption: Int
    @Published var authorSortOption: Int

    // Sync - Long Updates
    @Published var processedUpdateNumber: Int = 0
    @Published var totalUpdateCount: Int = 0

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
        $allSounds.eraseToAnyPublisher()
    }

    var favoritesPublisher: AnyPublisher<[Sound], Never> {
        $favorites.eraseToAnyPublisher()
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
                connectionManager: ConnectionManager.shared,
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
            allSounds = try LocalDatabase.shared.sounds(
                allowSensitive: UserSettings.getShowExplicitContent(),
                favoritesOnly: false
            )

            guard allSounds.count > 0 else { return }
            let sortOption: SoundSortOption = SoundSortOption(rawValue: soundSortOption) ?? .dateAddedDescending
            sort(&allSounds, by: sortOption)
        } catch {
            print("Erro carregando sons: \(error.localizedDescription)")
        }
    }

    func reloadFavorites() {
        do {
            favorites = try LocalDatabase.shared.sounds(
                allowSensitive: UserSettings.getShowExplicitContent(),
                favoritesOnly: true
            )

            guard favorites.count > 0 else { return }
            let sortOption: SoundSortOption = SoundSortOption(rawValue: soundSortOption) ?? .dateAddedDescending
            sort(&favorites, by: sortOption)
        } catch {
            print("Erro carregando sons: \(error.localizedDescription)")
        }
    }

    // MARK: - List Sorting

    func sortSounds(by rawSortOption: Int) {
        let sortOption = SoundSortOption(rawValue: rawSortOption) ?? .dateAddedDescending
        if currentViewMode == .allSounds {
            sort(&allSounds, by: sortOption)
        } else {
            sort(&favorites, by: sortOption)
        }
        UserSettings.saveMainSoundListSoundSortOption(rawSortOption)
    }

    private func sort(_ sounds: inout [Sound], by sortOption: SoundSortOption) {
        switch sortOption {
        case .titleAscending:
            sortByTitleAscending(&sounds)
        case .authorNameAscending:
            sortByAuthorNameAscending(&sounds)
        case .dateAddedDescending:
            sortByDateAddedDescending(&sounds)
        case .shortestFirst:
            sortByDurationAscending(&sounds)
        case .longestFirst:
            sortByDurationDescending(&sounds)
        case .longestTitleFirst:
            sortByTitleLengthDescending(&sounds)
        case .shortestTitleFirst:
            sortByTitleLengthAscending(&sounds)
        }
    }

    private func sortByTitleAscending(_ sounds: inout [Sound]) {
        sounds.sort(by: { $0.title.withoutDiacritics() < $1.title.withoutDiacritics() })
    }

    private func sortByAuthorNameAscending(_ sounds: inout [Sound]) {
        sounds.sort(by: { $0.authorName?.withoutDiacritics() ?? "" < $1.authorName?.withoutDiacritics() ?? "" })
    }

    private func sortByDateAddedDescending(_ sounds: inout [Sound]) {
        sounds.sort(by: { $0.dateAdded ?? Date() > $1.dateAdded ?? Date() })
    }

    private func sortByDurationAscending(_ sounds: inout [Sound]) {
        sounds.sort(by: { $0.duration < $1.duration })
    }

    private func sortByDurationDescending(_ sounds: inout [Sound]) {
        sounds.sort(by: { $0.duration > $1.duration })
    }

    private func sortByTitleLengthAscending(_ sounds: inout [Sound]) {
        sounds.sort(by: { $0.title.count < $1.title.count })
    }

    private func sortByTitleLengthDescending(_ sounds: inout [Sound]) {
        sounds.sort(by: { $0.title.count > $1.title.count })
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
            if UserSettings.getShowUpdateDateOnUI() {
                message += " \(LocalDatabase.shared.dateTimeOfLastUpdate())"
            }

            return displayToast(
                "clock.fill",
                .orange,
                toastText: message,
                displayTime: .seconds(UserSettings.getShowUpdateDateOnUI() ? 10 : 3)
            )
        }

        await syncManager.sync()

        print("SYNC EXECUTED")

        var message = syncValues.syncStatus.description
        if UserSettings.getShowUpdateDateOnUI() {
            message += " \(LocalDatabase.shared.dateTimeOfLastUpdate())"
        }

        displayToast(
            syncValues.syncStatus == .done ? "checkmark" : "exclamationmark.triangle.fill",
            syncValues.syncStatus == .done ? .green : .orange,
            toastText: message,
            displayTime: .seconds(UserSettings.getShowUpdateDateOnUI() ? 10 : 3)
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
