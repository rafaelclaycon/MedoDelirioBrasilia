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

    @Published var favoritesKeeper = Set<String>()

    // MARK: - Stored Properties

    var currentSoundsListMode: Binding<SoundsListMode>

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

    func reloadAllSounds() {
        do {
            allSounds = try LocalDatabase.shared.sounds(
                allowSensitive: UserSettings.getShowExplicitContent(),
                favoritesOnly: false
            )

            guard allSounds.count > 0 else { return }

            favoritesKeeper.removeAll()
            let favorites = try LocalDatabase.shared.favorites()
            if favorites.count > 0 {
                for favorite in favorites {
                    favoritesKeeper.insert(favorite.contentId)
                }
            }

            let sortOption: SoundSortOption = SoundSortOption(rawValue: UserSettings.getSoundSortOption()) ?? .dateAddedDescending
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

            favoritesKeeper.removeAll()
            let favoritesForKeeper = try LocalDatabase.shared.favorites()
            if favoritesForKeeper.count > 0 {
                for favorite in favoritesForKeeper {
                    favoritesKeeper.insert(favorite.contentId)
                }
            }

            let sortOption: SoundSortOption = SoundSortOption(rawValue: UserSettings.getSoundSortOption()) ?? .dateAddedDescending
            sort(&favorites, by: sortOption)
        } catch {
            print("Erro carregando sons: \(error.localizedDescription)")
        }
    }

    // MARK: - List Sorting

    func sort(_ sounds: inout [Sound], by sortOption: SoundSortOption) {
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
