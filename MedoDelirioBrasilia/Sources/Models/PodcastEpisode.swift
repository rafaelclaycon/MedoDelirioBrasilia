//
//  PodcastEpisode.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 17/02/26.
//

import Foundation

struct PodcastEpisode: Identifiable, Equatable {

    let id: String
    let title: String
    let pubDate: Date
    let audioURL: URL
    let description: String?
    let imageURL: URL?
    let duration: TimeInterval?
    let explicit: Bool

    var formattedDuration: String? {
        guard let duration else { return nil }
        let totalSeconds = Int(duration)
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
