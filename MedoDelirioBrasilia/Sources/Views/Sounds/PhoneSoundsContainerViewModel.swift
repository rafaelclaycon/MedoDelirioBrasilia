//
//  PhoneSoundsContainerViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 14/04/24.
//

import SwiftUI
import Combine

class PhoneSoundsContainerViewModel: ObservableObject, SoundDataProvider {

    @Published var sounds: [Sound] = []

    @Published var currentViewMode: SoundsViewMode
    @Published var soundSortOption: Int
    @Published var authorSortOption: Int

    @Published var favoritesKeeper = Set<String>()

    var currentSoundsListMode: Binding<SoundsListMode>

    var soundsPublisher: AnyPublisher<[Sound], Never> {
        $sounds.eraseToAnyPublisher()
    }

    // MARK: - Initializer

    init(
        currentViewMode: SoundsViewMode,
        soundSortOption: Int,
        authorSortOption: Int,
        currentSoundsListMode: Binding<SoundsListMode>//,
        //syncValues: SyncValues
    ) {
        self.currentViewMode = currentViewMode
        self.soundSortOption = soundSortOption
        self.authorSortOption = authorSortOption
        self.currentSoundsListMode = currentSoundsListMode

//        self.syncManager = SyncManager(
//            service: SyncService(
//                connectionManager: ConnectionManager.shared,
//                networkRabbit: NetworkRabbit.shared,
//                localDatabase: LocalDatabase.shared
//            ),
//            database: LocalDatabase.shared,
//            logger: Logger.shared
//        )
        // self.syncValues = syncValues
        // self.syncManager.delegate = self
    }

    // MARK: - Functions

    func reloadList(currentMode: SoundsViewMode) {
        guard currentMode == .allSounds || currentMode == .favorites else { return }

        do {
            sounds = try LocalDatabase.shared.sounds(
                allowSensitive: UserSettings.getShowExplicitContent(),
                favoritesOnly: currentMode == .favorites
            )

            guard sounds.count > 0 else { return }

            favoritesKeeper.removeAll()
            let favorites = try LocalDatabase.shared.favorites()
            if favorites.count > 0 {
                for favorite in favorites {
                    favoritesKeeper.insert(favorite.contentId)
                }
            }

            let sortOption: SoundSortOption = SoundSortOption(rawValue: UserSettings.getSoundSortOption()) ?? .dateAddedDescending
            sortSounds(by: sortOption)
        } catch {
            print("Erro carregando sons: \(error.localizedDescription)")
        }
    }

    func sortSounds(by sortOption: SoundSortOption) {
        switch sortOption {
        case .titleAscending:
            sortSoundsInPlaceByTitleAscending()
        case .authorNameAscending:
            sortSoundsInPlaceByAuthorNameAscending()
        case .dateAddedDescending:
            sortSoundsInPlaceByDateAddedDescending()
        case .shortestFirst:
            sortSoundsInPlaceByDurationAscending()
        case .longestFirst:
            sortSoundsInPlaceByDurationDescending()
        case .longestTitleFirst:
            sortSoundsInPlaceByTitleLengthDescending()
        case .shortestTitleFirst:
            sortSoundsInPlaceByTitleLengthAscending()
        }
    }

    private func sortSoundsInPlaceByTitleAscending() {
        sounds.sort(by: { $0.title.withoutDiacritics() < $1.title.withoutDiacritics() })
    }

    private func sortSoundsInPlaceByAuthorNameAscending() {
        sounds.sort(by: { $0.authorName?.withoutDiacritics() ?? "" < $1.authorName?.withoutDiacritics() ?? "" })
    }

    private func sortSoundsInPlaceByDateAddedDescending() {
        sounds.sort(by: { $0.dateAdded ?? Date() > $1.dateAdded ?? Date() })
    }

    private func sortSoundsInPlaceByDurationAscending() {
        sounds.sort(by: { $0.duration < $1.duration })
    }

    private func sortSoundsInPlaceByDurationDescending() {
        sounds.sort(by: { $0.duration > $1.duration })
    }

    private func sortSoundsInPlaceByTitleLengthAscending() {
        sounds.sort(by: { $0.title.count < $1.title.count })
    }

    private func sortSoundsInPlaceByTitleLengthDescending() {
        sounds.sort(by: { $0.title.count > $1.title.count })
    }
}
