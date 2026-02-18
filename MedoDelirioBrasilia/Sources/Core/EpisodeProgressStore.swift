//
//  EpisodeProgressStore.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 18/02/26.
//

import Foundation

@Observable
final class EpisodeProgressStore {

    struct EpisodeProgress: Codable {
        var currentTime: TimeInterval
        var duration: TimeInterval
    }

    private static let legacyKey = "episodePlaybackProgress"

    @ObservationIgnored private let database: LocalDatabaseProtocol

    private(set) var entries: [String: EpisodeProgress]

    init(database: LocalDatabaseProtocol = LocalDatabase.shared) {
        self.database = database

        let dbEntries = (try? database.allEpisodeProgress()) ?? [:]
        var converted = [String: EpisodeProgress]()
        for (id, value) in dbEntries {
            converted[id] = EpisodeProgress(currentTime: value.currentTime, duration: value.duration)
        }
        self.entries = converted

        migrateFromUserDefaultsIfNeeded()
    }

    // MARK: - Public API

    func progress(for episodeID: String) -> EpisodeProgress? {
        entries[episodeID]
    }

    func save(episodeID: String, currentTime: TimeInterval, duration: TimeInterval) {
        guard duration > 0 else { return }
        entries[episodeID] = EpisodeProgress(currentTime: currentTime, duration: duration)
        try? database.upsertEpisodeProgress(episodeId: episodeID, currentTime: currentTime, duration: duration)
    }

    func clear(episodeID: String) {
        entries.removeValue(forKey: episodeID)
        try? database.deleteEpisodeProgress(episodeId: episodeID)
    }

    func fractionCompleted(for episodeID: String) -> Double? {
        guard let entry = entries[episodeID], entry.duration > 0 else { return nil }
        return min(entry.currentTime / entry.duration, 1.0)
    }

    func timeRemaining(for episodeID: String) -> TimeInterval? {
        guard let entry = entries[episodeID] else { return nil }
        return max(entry.duration - entry.currentTime, 0)
    }

    /// Formats the remaining time as a human-readable string (e.g. "45 min left", "1 hr 12 min left").
    func formattedTimeRemaining(for episodeID: String) -> String? {
        guard let remaining = timeRemaining(for: episodeID), remaining > 0 else { return nil }
        let totalMinutes = Int(remaining) / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if hours > 0 && minutes > 0 {
            return "\(hours) hr \(minutes) min restantes"
        } else if hours > 0 {
            return "\(hours) hr restantes"
        } else if minutes > 0 {
            return "\(minutes) min restantes"
        } else {
            return "< 1 min restante"
        }
    }

    // MARK: - Legacy Migration

    private func migrateFromUserDefaultsIfNeeded() {
        guard let data = UserDefaults.standard.data(forKey: Self.legacyKey),
              let decoded = try? JSONDecoder().decode([String: EpisodeProgress].self, from: data) else {
            return
        }
        for (id, progress) in decoded {
            try? database.upsertEpisodeProgress(
                episodeId: id,
                currentTime: progress.currentTime,
                duration: progress.duration
            )
        }
        UserDefaults.standard.removeObject(forKey: Self.legacyKey)

        let dbEntries = (try? database.allEpisodeProgress()) ?? [:]
        var converted = [String: EpisodeProgress]()
        for (id, value) in dbEntries {
            converted[id] = EpisodeProgress(currentTime: value.currentTime, duration: value.duration)
        }
        entries = converted
    }
}
