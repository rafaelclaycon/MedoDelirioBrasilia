//
//  EpisodeFavoritesStore.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 17/02/26.
//

import Foundation

@Observable
final class EpisodeFavoritesStore {

    private static let legacyKey = "favoritedEpisodeIDs"

    @ObservationIgnored private let database: LocalDatabaseProtocol

    private(set) var favoriteIDs: Set<String>

    init(database: LocalDatabaseProtocol = LocalDatabase.shared) {
        self.database = database
        self.favoriteIDs = (try? database.allEpisodeFavoriteIDs()) ?? []
        migrateFromUserDefaultsIfNeeded()
    }

    func isFavorite(_ episodeID: String) -> Bool {
        favoriteIDs.contains(episodeID)
    }

    func toggle(_ episodeID: String) {
        if favoriteIDs.contains(episodeID) {
            favoriteIDs.remove(episodeID)
            try? database.deleteEpisodeFavorite(episodeId: episodeID)
        } else {
            favoriteIDs.insert(episodeID)
            try? database.insertEpisodeFavorite(episodeId: episodeID)
        }
    }

    // MARK: - Legacy Migration

    private func migrateFromUserDefaultsIfNeeded() {
        guard let legacy = UserDefaults.standard.stringArray(forKey: Self.legacyKey) else { return }
        for id in legacy {
            try? database.insertEpisodeFavorite(episodeId: id)
        }
        UserDefaults.standard.removeObject(forKey: Self.legacyKey)
        favoriteIDs = (try? database.allEpisodeFavoriteIDs()) ?? favoriteIDs
    }
}
