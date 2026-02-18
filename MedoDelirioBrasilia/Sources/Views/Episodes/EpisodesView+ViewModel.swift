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
        private let database: LocalDatabaseProtocol

        private static let feedURL = URL(string: "https://www.spreaker.com/show/4711842/episodes/feed")!

        // MARK: - Initializer

        init(
            episodesService: EpisodesServiceProtocol,
            database: LocalDatabaseProtocol = LocalDatabase.shared
        ) {
            self.episodesService = episodesService
            self.database = database
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
        await syncFromNetwork()
    }
}

// MARK: - Internal Functions

extension EpisodesView.ViewModel {

    private func loadEpisodes() async {
        let cached = (try? database.allPodcastEpisodes()) ?? []

        if cached.isEmpty {
            state = .loading
        } else {
            state = .loaded(cached)
        }

        await syncFromNetwork()
    }

    private func syncFromNetwork() async {
        do {
            let episodes = try await episodesService.fetchEpisodes(from: Self.feedURL)
            try database.upsertPodcastEpisodes(episodes)
            let refreshed = try database.allPodcastEpisodes()
            state = .loaded(refreshed)
        } catch {
            if case .loading = state {
                state = .error(error.localizedDescription)
            }
        }
    }
}
