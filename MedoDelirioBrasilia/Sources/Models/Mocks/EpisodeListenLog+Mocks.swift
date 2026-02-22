//
//  EpisodeListenLog+Mocks.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 17/02/26.
//

import Foundation

extension EpisodeListenLog {

    static func mock(
        id: String = UUID().uuidString,
        episodeId: String = "ep-1",
        startedAt: Date = Date(),
        durationListened: Double = 1800,
        didComplete: Bool = false
    ) -> EpisodeListenLog {
        EpisodeListenLog(
            id: id,
            episodeId: episodeId,
            startedAt: startedAt,
            endedAt: startedAt.addingTimeInterval(durationListened),
            durationListened: durationListened,
            didComplete: didComplete
        )
    }
}
