//
//  EpisodeBookmark.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 18/02/26.
//

import Foundation

struct EpisodeBookmark: Identifiable, Equatable {

    let id: String
    let episodeId: String
    let timestamp: TimeInterval
    var title: String?
    var note: String?
    let createdAt: Date

    init(
        id: String = UUID().uuidString,
        episodeId: String,
        timestamp: TimeInterval,
        title: String? = nil,
        note: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.episodeId = episodeId
        self.timestamp = timestamp
        self.title = title
        self.note = note
        self.createdAt = createdAt
    }

    var formattedTimestamp: String {
        let totalSeconds = max(Int(timestamp), 0)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}
