//
//  EpisodesView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 17/02/26.
//

import SwiftUI

struct EpisodesView: View {

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
                        EpisodeRow(episode: episode)
                    }
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

        var body: some View {
            VStack(alignment: .leading, spacing: .spacing(.xxxSmall)) {
                Text(episode.title)
                    .font(.headline)
                    .lineLimit(2)

                HStack(spacing: .spacing(.xxSmall)) {
                    Text(episode.pubDate, format: .dateTime.day().month(.wide).year())
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if let formattedDuration = episode.formattedDuration {
                        Text("·")
                            .foregroundStyle(.secondary)

                        Text(formattedDuration)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                if let description = episode.description {
                    Text(description)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            .padding(.vertical, .spacing(.xxxSmall))
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

// MARK: - Preview

#Preview {
    NavigationStack {
        EpisodesView()
    }
}
