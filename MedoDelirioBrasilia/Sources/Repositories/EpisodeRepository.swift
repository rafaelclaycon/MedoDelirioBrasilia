//
//  EpisodeRepository.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 01/12/24.
//

import Foundation
import FeedKit

protocol EpisodeRepositoryProtocol {

    func latestEpisodes() async throws -> [Episode]
}

final class EpisodeRepository: EpisodeRepositoryProtocol {

    private let apiClient: NetworkRabbitProtocol

    init(
        apiClient: NetworkRabbitProtocol = NetworkRabbit(serverPath: APIConfig.apiURL)
    ) {
        self.apiClient = apiClient
    }

    func latestEpisodes() async throws -> [Episode] {
        let url = URL(string: "https://www.central3.com.br/category/podcasts/medo-e-delirio/feed/podcast/")!
        let parser = FeedParser(URL: url)

        let result = await withCheckedContinuation { continuation in
            parser.parseAsync { result in
                continuation.resume(returning: result)
            }
        }

        switch result {
        case let .success(feed):
            guard let feed = feed.rssFeed else {
                throw EpisodeRepositoryError.notAnRSSFeed
            }
            guard let items = feed.items else {
                throw EpisodeRepositoryError.emptyFeed
            }

            // podcast.artworkUrl = feed.iTunes?.iTunesImage?.attributes?.href ?? feed.image?.url ?? .empty

//            if podcast.artworkUrl.isEmpty == false, podcast.artworkUrl.contains("https") == false {
//                do {
//                    podcast.artworkUrl = try LinkWizard.fixURLfromHTTPToHTTPS(podcast.artworkUrl)
//                } catch {
//                    print("Failed to correct artwork link for \(podcast.title). URL: \(podcast.artworkUrl) Error: \(error.localizedDescription)")
//                }
//            }

            //podcast.lastCheckDate = Date()

            return items.prefix(6).map { item in
                Episode(
                    episodeId: item.guid?.value ?? UUID().uuidString,
                    title: item.title ?? "SEM TÍTULO",
                    description: item.iTunes?.iTunesSubtitle,
                    pubDate: item.pubDate,
                    duration: item.iTunes?.iTunesDuration ?? 0,
                    creationDate: .now
                )
            }

        case .failure(_):
            throw EpisodeRepositoryError.unableToAccessRSSFeed
        }
    }
}

enum EpisodeRepositoryError: Error {

    case notAnRSSFeed
    case emptyFeed
    case unableToAccessRSSFeed
}
