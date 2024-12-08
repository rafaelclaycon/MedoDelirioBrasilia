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
        @Published var playerState: PlayerState<Episode> = .stopped

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

    public func onPlayEpisodeSelected(episode: Episode) async {
        var episodeCopy = episode
        do {
            playerState = .downloading
            episodeCopy.localUrl = try await episodeRepository.download(episode: episode)
            play(episode: episodeCopy)
        } catch {
            print(error)
        }
    }

    public func onPlayPauseButtonSelected() {
        print("Not implemented yet")
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

    private func play(episode: Episode) {
        guard let url = episode.localUrl else { return }

        playerState = .playing(episode)

        AudioPlayer.shared = AudioPlayer(
            url: url,
            update: { [weak self] state in
                self?.onAudioPlayerUpdate(playerState: state)
            }
        )

        AudioPlayer.shared?.togglePlay()
    }

    private func onAudioPlayerUpdate(
        playerState: AudioPlayer.State?
    ) {
        guard playerState?.activity == .stopped else { return }
        self.playerState = .stopped
    }
}
