//
//  EpisodesView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 17/02/26.
//

import SwiftUI

struct EpisodesView: View {

    @Environment(EpisodePlayer.self) private var episodePlayer
    @Environment(EpisodeFavoritesStore.self) private var favoritesStore
    @Environment(EpisodeProgressStore.self) private var progressStore
    @Environment(EpisodePlayedStore.self) private var playedStore
    @Environment(\.push) private var push
    @State private var viewModel = ViewModel(episodesService: EpisodesService())

    // MARK: - View Body

    var body: some View {
        GeometryReader { geometry in
            switch viewModel.state {
            case .loading:
                LoadingView(
                    width: geometry.size.width,
                    height: geometry.size.height
                )

            case .loaded(let episodes):
                if episodes.isEmpty {
                    ContentUnavailableView(
                        "Nenhum Episódio",
                        systemImage: "radio",
                        description: Text("Não foi possível encontrar episódios no momento.")
                    )
                } else {
                    List(episodes) { episode in
                        EpisodeRow(
                            episode: episode,
                            episodePlayer: episodePlayer,
                            isFavorite: favoritesStore.isFavorite(episode.id),
                            progress: progressStore.progress(for: episode.id),
                            isPlayed: playedStore.isPlayed(episode.id)
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            push(episode)
                        }
                        .swipeActions(edge: .trailing) {
                            Button {
                                playedStore.toggle(episode.id)
                            } label: {
                                Label(
                                    playedStore.isPlayed(episode.id) ? "Marcar como Não Ouvido" : "Marcar como Ouvido",
                                    systemImage: playedStore.isPlayed(episode.id) ? "ear.slash" : "ear"
                                )
                            }
                            .tint(.gray)
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                favoritesStore.toggle(episode.id)
                            } label: {
                                Label(
                                    favoritesStore.isFavorite(episode.id) ? "Desfavoritar" : "Favoritar",
                                    systemImage: favoritesStore.isFavorite(episode.id) ? "star.slash" : "star"
                                )
                            }
                            .tint(.yellow)
                        }
                        .listRowSeparator(.visible)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await viewModel.onPullToRefresh()
                    }
                }

            case .error(let errorString):
                ErrorView(
                    error: errorString,
                    tryAgainAction: {
                        Task {
                            await viewModel.onTryAgainSelected()
                        }
                    },
                    width: geometry.size.width,
                    height: geometry.size.height
                )
            }
        }
        .navigationTitle("Episódios")
        .oneTimeTask {
            await viewModel.onViewLoaded()
        }
    }
}

// MARK: - Subviews

extension EpisodesView {

    struct EpisodeRow: View {

        let episode: PodcastEpisode
        let episodePlayer: EpisodePlayer
        let isFavorite: Bool
        let progress: EpisodeProgressStore.EpisodeProgress?
        let isPlayed: Bool

        private var isThisEpisodePlaying: Bool {
            episodePlayer.isCurrentEpisode(episode) && episodePlayer.isPlaying
        }

        private var hasProgress: Bool {
            guard let progress else { return false }
            return progress.currentTime > 0 && progress.duration > 0
        }

        var body: some View {
            HStack(spacing: .spacing(.xSmall)) {
                VStack(alignment: .leading, spacing: .spacing(.xSmall)) {
                    HStack(spacing: .spacing(.xxxSmall)) {
                        Text(episode.formattedDate)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)

                        if isFavorite {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundStyle(.yellow)
                        }
                    }

                    Text(episode.title)
                        .font(.title2)
                        .fontDesign(.serif)
                        .lineLimit(2)

                    HStack(spacing: .spacing(.xSmall)) {
                        if let plainText = episode.plainTextDescription {
                            Text(plainText)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }

                        if hasProgress, let progress {
                            Spacer(minLength: 0)

                            ProgressView(value: progress.currentTime, total: progress.duration)
                                .tint(.blue)
                                .frame(width: 100, height: 6)
                        }
                    }
                }

                Spacer(minLength: 0)

                VStack(spacing: .spacing(.xSmall)) {
                    playButton

                    if hasProgress, let progress {
                        Text(Self.formatTimeRemaining(progress.duration - progress.currentTime))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    } else if let formattedDuration = episode.formattedDuration {
                        Text(formattedDuration)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(width: 60)
            }
            .padding(.vertical, .spacing(.small))
            .opacity(isPlayed ? 0.5 : 1.0)
        }

        private static func formatTimeRemaining(_ remaining: TimeInterval) -> String {
            let totalMinutes = Int(max(remaining, 0)) / 60
            let hours = totalMinutes / 60
            let minutes = totalMinutes % 60

            if hours > 0 && minutes > 0 {
                return "\(hours) hr \(minutes) min restantes"
            } else if hours > 0 {
                return "\(hours) hr restantes"
            } else if minutes > 0 {
                return "\(minutes) min restantes"
            } else {
                return "< 1 min restante"
            }
        }

        @ViewBuilder
        private var playButton: some View {
            if episodePlayer.isDownloading(episode) {
                downloadProgressIndicator
            } else {
                if #available(iOS 26.0, *) {
                    Button {
                        Task {
                            await episodePlayer.play(episode: episode)
                        }
                    } label: {
                        Image(systemName: isThisEpisodePlaying ? "pause.fill" : "play.fill")
                            .font(.title2)
                            .foregroundStyle(.primary)
                    }
                    .buttonStyle(.borderless)
                    .padding(.spacing(.small))
                    .glassEffect(
                        .regular.tint(
                            Color.green.opacity(0.3)
                        ).interactive()
                    )
                } else {
                    Button {
                        Task {
                            await episodePlayer.play(episode: episode)
                        }
                    } label: {
                        Image(systemName: isThisEpisodePlaying ? "pause.fill" : "play.fill")
                            .font(.title2)
                            .foregroundStyle(.primary)
                    }
                    .buttonStyle(.borderless)
                }
            }
        }

        private var downloadProgressIndicator: some View {
            ZStack {
                Circle()
                    .stroke(Color.primary.opacity(0.2), lineWidth: 3)

                Circle()
                    .trim(from: 0, to: episodePlayer.downloadProgress[episode.id] ?? 0)
                    .stroke(Color.primary, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: 32, height: 32)
        }

    }

    struct LoadingView: View {

        let width: CGFloat
        let height: CGFloat

        var body: some View {
            VStack(spacing: 50) {
                ProgressView()
                    .scaleEffect(2.0)

                Text("Carregando Episódios...")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.gray)
            }
            .frame(width: width)
            .frame(minHeight: height)
        }
    }

    struct ErrorView: View {

        let error: String
        let tryAgainAction: () -> Void
        let width: CGFloat
        let height: CGFloat

        var body: some View {
            VStack(spacing: 30) {
                Text("☹️")
                    .font(.system(size: 86))

                Text("Erro ao Carregar os Episódios")
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)

                Text(error)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.gray)

                Button {
                    tryAgainAction()
                } label: {
                    Label("Tentar Novamente", systemImage: "arrow.clockwise")
                }
            }
            .padding(.horizontal, 20)
            .frame(width: width)
            .frame(minHeight: height)
        }
    }
}

// MARK: - Liquid Glass Helper

private extension View {

    @ViewBuilder
    func if_iOS26GlassElseBorderless() -> some View {
        if #available(iOS 26.0, *) {
            self.buttonStyle(.glass)
        } else {
            self.buttonStyle(.borderless)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        EpisodesView()
    }
    .environment(EpisodePlayer())
    .environment(EpisodeFavoritesStore())
    .environment(EpisodeProgressStore())
    .environment(EpisodePlayedStore())
}
