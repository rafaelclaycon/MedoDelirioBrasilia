//
//  EpisodeListenLog.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 17/02/26.
//

import Foundation

struct EpisodeListenLog: Hashable, Codable, Identifiable {

    var id: String
    var episodeId: String
    var startedAt: Date
    var endedAt: Date
    var durationListened: Double
    var didComplete: Bool

    init(
        id: String = UUID().uuidString,
        episodeId: String,
        startedAt: Date,
        endedAt: Date,
        durationListened: Double,
        didComplete: Bool
    ) {
        self.id = id
        self.episodeId = episodeId
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.durationListened = durationListened
        self.didComplete = didComplete
    }
}
