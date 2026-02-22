//
//  EpisodeListenStore.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 17/02/26.
//

import Foundation

@Observable
final class EpisodeListenStore {

    @ObservationIgnored private let database: LocalDatabaseProtocol

    init(database: LocalDatabaseProtocol = LocalDatabase.shared) {
        self.database = database
    }

    // MARK: - Recording

    func recordSession(
        episodeId: String,
        startedAt: Date,
        endedAt: Date,
        durationListened: Double,
        didComplete: Bool
    ) {
        guard durationListened > 0 else { return }
        let log = EpisodeListenLog(
            episodeId: episodeId,
            startedAt: startedAt,
            endedAt: endedAt,
            durationListened: durationListened,
            didComplete: didComplete
        )
        try? database.insertEpisodeListenLog(log)
    }

    // MARK: - Queries

    func allLogs() -> [EpisodeListenLog] {
        (try? database.allEpisodeListenLogs()) ?? []
    }

    func logs(for episodeId: String) -> [EpisodeListenLog] {
        (try? database.episodeListenLogs(forEpisodeId: episodeId)) ?? []
    }

    func allListenDates() -> [Date] {
        (try? database.allListenDates()) ?? []
    }
}
