//
//  EpisodePlayedStore.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 18/02/26.
//

import Foundation

@Observable
final class EpisodePlayedStore {

    private static let key = "playedEpisodeIDs"

    private(set) var playedIDs: Set<String>

    init() {
        let stored = UserDefaults.standard.stringArray(forKey: Self.key) ?? []
        playedIDs = Set(stored)
    }

    func isPlayed(_ episodeID: String) -> Bool {
        playedIDs.contains(episodeID)
    }

    func toggle(_ episodeID: String) {
        if playedIDs.contains(episodeID) {
            playedIDs.remove(episodeID)
        } else {
            playedIDs.insert(episodeID)
        }
        persist()
    }

    private func persist() {
        UserDefaults.standard.set(Array(playedIDs), forKey: Self.key)
    }
}
