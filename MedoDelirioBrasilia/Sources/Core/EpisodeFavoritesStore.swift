//
//  EpisodeFavoritesStore.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 17/02/26.
//

import Foundation

@Observable
final class EpisodeFavoritesStore {

    private static let key = "favoritedEpisodeIDs"

    private(set) var favoriteIDs: Set<String>

    init() {
        let stored = UserDefaults.standard.stringArray(forKey: Self.key) ?? []
        favoriteIDs = Set(stored)
    }

    func isFavorite(_ episodeID: String) -> Bool {
        favoriteIDs.contains(episodeID)
    }

    func toggle(_ episodeID: String) {
        if favoriteIDs.contains(episodeID) {
            favoriteIDs.remove(episodeID)
        } else {
            favoriteIDs.insert(episodeID)
        }
        persist()
    }

    private func persist() {
        UserDefaults.standard.set(Array(favoriteIDs), forKey: Self.key)
    }
}
