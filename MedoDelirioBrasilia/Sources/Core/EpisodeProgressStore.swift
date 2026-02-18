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

    private static let key = "episodePlaybackProgress"

    private(set) var entries: [String: EpisodeProgress]

    init() {
        guard let data = UserDefaults.standard.data(forKey: Self.key),
              let decoded = try? JSONDecoder().decode([String: EpisodeProgress].self, from: data) else {
            entries = [:]
            return
        }
        entries = decoded
    }

    // MARK: - Public API

    func progress(for episodeID: String) -> EpisodeProgress? {
        entries[episodeID]
    }

    func save(episodeID: String, currentTime: TimeInterval, duration: TimeInterval) {
        guard duration > 0 else { return }
        entries[episodeID] = EpisodeProgress(currentTime: currentTime, duration: duration)
        persist()
    }

    func clear(episodeID: String) {
        entries.removeValue(forKey: episodeID)
        persist()
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

    // MARK: - Persistence

    private func persist() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        UserDefaults.standard.set(data, forKey: Self.key)
    }
}
