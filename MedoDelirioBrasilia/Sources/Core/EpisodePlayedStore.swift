//
//  EpisodePlayedStore.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 18/02/26.
//

import Foundation

@Observable
final class EpisodePlayedStore {

    private static let legacyKey = "playedEpisodeIDs"

    @ObservationIgnored private let database: LocalDatabaseProtocol

    private(set) var playedIDs: Set<String>

    init(database: LocalDatabaseProtocol = LocalDatabase.shared) {
        self.database = database
        self.playedIDs = (try? database.allEpisodePlayedIDs()) ?? []
        migrateFromUserDefaultsIfNeeded()
    }

    func isPlayed(_ episodeID: String) -> Bool {
        playedIDs.contains(episodeID)
    }

    func toggle(_ episodeID: String) {
        if playedIDs.contains(episodeID) {
            playedIDs.remove(episodeID)
            try? database.deleteEpisodePlayed(episodeId: episodeID)
        } else {
            playedIDs.insert(episodeID)
            try? database.insertEpisodePlayed(episodeId: episodeID)
        }
    }

    // MARK: - Legacy Migration

    private func migrateFromUserDefaultsIfNeeded() {
        guard let legacy = UserDefaults.standard.stringArray(forKey: Self.legacyKey) else { return }
        for id in legacy {
            try? database.insertEpisodePlayed(episodeId: id)
        }
        UserDefaults.standard.removeObject(forKey: Self.legacyKey)
        playedIDs = (try? database.allEpisodePlayedIDs()) ?? playedIDs
    }
}
