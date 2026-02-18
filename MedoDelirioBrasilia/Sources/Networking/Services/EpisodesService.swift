//
//  EpisodesService.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 17/02/26.
//

import Foundation
import FeedKit

protocol EpisodesServiceProtocol {

    func fetchEpisodes(from url: URL) async throws -> [PodcastEpisode]
}

@MainActor
final class EpisodesService: EpisodesServiceProtocol {

    func fetchEpisodes(from url: URL) async throws -> [PodcastEpisode] {
        let (data, _) = try await URLSession.shared.data(from: url)

        let episodes: [PodcastEpisode] = try await Task.detached {
            let feed = try Feed(data: data)

            guard let rssFeed = feed.rss else {
                throw EpisodesServiceError.invalidFeedFormat
            }

            return (rssFeed.channel?.items ?? []).compactMap { item in
                Self.mapToPodcastEpisode(item)
            }
        }.value

        return episodes.sorted { $0.pubDate > $1.pubDate }
    }

    // MARK: - Mapping

    private nonisolated static func mapToPodcastEpisode(_ item: RSSFeedItem) -> PodcastEpisode? {
        guard let title = item.title,
              let pubDate = item.pubDate,
              let audioURLString = item.enclosure?.attributes?.url,
              let audioURL = URL(string: audioURLString) else {
            return nil
        }

        let imageURL: URL? = item.iTunes?.image?.attributes?.href.flatMap { URL(string: $0) }

        return PodcastEpisode(
            id: item.guid?.text ?? UUID().uuidString,
            title: title,
            pubDate: pubDate,
            audioURL: audioURL,
            description: item.iTunes?.summary ?? item.description,
            imageURL: imageURL,
            duration: item.iTunes?.duration,
            explicit: item.iTunes?.explicit == "yes"
        )
    }
}

// MARK: - Errors

enum EpisodesServiceError: Error, LocalizedError {

    case invalidFeedFormat

    var errorDescription: String? {
        switch self {
        case .invalidFeedFormat:
            return "O feed do podcast possui um formato inválido."
        }
    }
}
