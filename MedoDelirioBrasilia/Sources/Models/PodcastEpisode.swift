//
//  PodcastEpisode.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 17/02/26.
//

import Foundation

struct PodcastEpisode: Identifiable, Equatable, Hashable {

    let id: String
    let title: String
    let pubDate: Date
    let audioURL: URL
    let description: String?
    let imageURL: URL?
    let duration: TimeInterval?
    let explicit: Bool

    /// The episode description with HTML tags stripped and entities decoded.
    var plainTextDescription: String? {
        description?.strippingHTML()
    }

    /// Returns a relative date string (e.g. "Today", "3 days ago") for episodes
    /// published within the last week, and an absolute date for older episodes.
    var formattedDate: String {
        let calendar = Calendar.current
        let now = Date()

        if let daysAgo = calendar.dateComponents([.day], from: calendar.startOfDay(for: pubDate), to: calendar.startOfDay(for: now)).day,
           daysAgo >= 0, daysAgo <= 7 {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            return formatter.localizedString(for: pubDate, relativeTo: now)
        } else {
            return pubDate.formatted(.dateTime.day().month(.wide).year())
        }
    }

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
