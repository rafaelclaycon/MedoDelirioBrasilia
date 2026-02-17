//
//  EpisodesView+ViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 17/02/26.
//

import Foundation

extension EpisodesView {

    @Observable class ViewModel {

        var state: LoadingState<[PodcastEpisode]> = .loading

        private let episodesService: EpisodesServiceProtocol

        private static let feedURL = URL(string: "https://www.spreaker.com/show/4711842/episodes/feed")!
        private static let episodeLimit = 20

        // MARK: - Initializer

        init(
            episodesService: EpisodesServiceProtocol
        ) {
            self.episodesService = episodesService
        }
    }
}

// MARK: - User Actions

extension EpisodesView.ViewModel {

    func onViewLoaded() async {
        await loadEpisodes()
    }

    func onTryAgainSelected() async {
        await loadEpisodes()
    }

    func onPullToRefresh() async {
        await loadEpisodes()
    }
}

// MARK: - Internal Functions

extension EpisodesView.ViewModel {

    private func loadEpisodes() async {
        state = .loading

        do {
            let episodes = try await episodesService.fetchEpisodes(
                from: Self.feedURL,
                limit: Self.episodeLimit
            )
            state = .loaded(episodes)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
