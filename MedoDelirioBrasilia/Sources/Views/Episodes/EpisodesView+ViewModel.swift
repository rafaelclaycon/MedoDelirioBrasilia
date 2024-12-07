//
//  EpisodesView+ViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 01/12/24.
//

import Foundation

extension EpisodesView {

    @MainActor
    final class ViewModel: ObservableObject {

        @Published var state: LoadingState<[Episode]> = .loading

        private let episodeRepository: EpisodeRepositoryProtocol

        // MARK: - Initializer

        init(
            episodeRepository: EpisodeRepositoryProtocol
        ) {
            self.episodeRepository = episodeRepository
        }
    }
}

// MARK: - User Actions

extension EpisodesView.ViewModel {

    public func onViewLoaded() async {
        await loadEpisodes()
    }
}

// MARK: - Internal Functions

extension EpisodesView.ViewModel {

    private func loadEpisodes() async {
        state = .loading

        do {
            let episodes = try await episodeRepository.latestEpisodes()
            state = .loaded(episodes)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
