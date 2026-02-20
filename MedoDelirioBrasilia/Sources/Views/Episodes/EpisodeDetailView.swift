//
//  EpisodeDetailView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 17/02/26.
//

import SwiftUI

struct EpisodeDetailView: View {

    let episode: PodcastEpisode
    @Environment(EpisodePlayer.self) private var episodePlayer
    @Environment(EpisodeFavoritesStore.self) private var favoritesStore
    @Environment(EpisodeProgressStore.self) private var progressStore
    @Environment(EpisodePlayedStore.self) private var playedStore
    @Environment(EpisodeBookmarkStore.self) private var bookmarkStore

    @State private var editingBookmark: EpisodeBookmark?

    private var isPlayed: Bool {
        playedStore.isPlayed(episode.id)
    }

    private var isThisEpisodePlaying: Bool {
        episodePlayer.isCurrentEpisode(episode) && episodePlayer.isPlaying
    }

    private var episodeProgress: EpisodeProgressStore.EpisodeProgress? {
        progressStore.progress(for: episode.id)
    }

    private var hasProgress: Bool {
        guard let episodeProgress else { return false }
        return episodeProgress.currentTime > 0 && episodeProgress.duration > 0
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .spacing(.medium)) {
                header

                Divider()

                if let plainText = episode.plainTextDescription {
                    Text(plainText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                bookmarkSection
            }
            .padding(.horizontal, .spacing(.medium))
            .padding(.vertical, .spacing(.small))
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $editingBookmark) { bookmark in
            BookmarkEditView(bookmark: bookmark)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    favoritesStore.toggle(episode.id)
                } label: {
                    Image(systemName: favoritesStore.isFavorite(episode.id) ? "star.fill" : "star")
                        .foregroundStyle(favoritesStore.isFavorite(episode.id) ? .yellow : .primary)
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: .spacing(.xSmall)) {
            HStack(spacing: .spacing(.xxxSmall)) {
                Text(episode.formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)

                if favoritesStore.isFavorite(episode.id) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundStyle(.yellow)
                }
            }

            Text(episode.title)
                .font(.title)
                .fontDesign(.serif)

            HStack(spacing: .spacing(.medium)) {
                playButton

                if isPlayed {
                    Image(systemName: "checkmark")
                        .font(.subheadline)
                        .foregroundStyle(.secondary.opacity(0.5))
                } else if hasProgress, let episodeProgress {
                    Text(Self.formatTimeRemaining(episodeProgress.duration - episodeProgress.currentTime))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else if let formattedDuration = episode.formattedDuration {
                    Text(formattedDuration)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, .spacing(.xxxSmall))

            if hasProgress, let episodeProgress {
                ProgressView(value: episodeProgress.currentTime, total: episodeProgress.duration)
                    .tint(.primary)
            }
        }
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

    // MARK: - Play Button

    @ViewBuilder
    private var playButton: some View {
        if episodePlayer.isDownloading(episode) {
            downloadProgressIndicator
        } else {
            Button {
                Task {
                    await episodePlayer.play(episode: episode)
                }
            } label: {
                Label(
                    isThisEpisodePlaying ? "Pausar" : "Ouvir",
                    systemImage: isThisEpisodePlaying ? "pause.fill" : "play.fill"
                )
                .font(.subheadline)
                .fontWeight(.semibold)
            }
            .if_iOS26GlassElseBorderedProminent()
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

    // MARK: - Bookmarks

    private var episodeBookmarks: [EpisodeBookmark] {
        bookmarkStore.bookmarks(for: episode.id)
    }

    @ViewBuilder
    private var bookmarkSection: some View {
        let bookmarks = episodeBookmarks
        if !bookmarks.isEmpty {
            Divider()

            VStack(alignment: .leading, spacing: 0) {
                Text("Marcadores")
                    .font(.headline)
                    .padding(.bottom, .spacing(.small))

                ForEach(Array(bookmarks.enumerated()), id: \.element.id) { index, bookmark in
                    detailBookmarkRow(bookmark)

                    if index < bookmarks.count - 1 {
                        Divider()
                    }
                }
            }
        }
    }

    private func detailBookmarkRow(_ bookmark: EpisodeBookmark) -> some View {
        HStack(spacing: .spacing(.small)) {
            Image(systemName: "bookmark.fill")
                .foregroundStyle(Color.rubyRed)
                .font(.body)

            Text(bookmark.formattedTimestamp)
                .font(.body)
                .monospacedDigit()
                .foregroundStyle(Color.rubyRed)

            Text(bookmark.title ?? "Sem título")
                .font(.body)
                .foregroundStyle(bookmark.title != nil ? .primary : .secondary)
                .lineLimit(1)

            Spacer()

            Button {
                Task {
                    await episodePlayer.play(episode: episode)
                    episodePlayer.seek(to: bookmark.timestamp)
                }
            } label: {
                Image(systemName: "play.fill")
                    .font(.body)
                    .foregroundStyle(Color.rubyRed)
                    .padding(.spacing(.xxxSmall))
            }
            .if_iOS26GlassElsePlain()
        }
        .padding(.vertical, .spacing(.small))
        .contentShape(Rectangle())
        .onTapGesture {
            editingBookmark = bookmark
        }
        .contextMenu {
            Button(role: .destructive) {
                withAnimation {
                    bookmarkStore.delete(id: bookmark.id, episodeId: bookmark.episodeId)
                }
            } label: {
                Label("Excluir", systemImage: "trash")
            }
        }
    }
}

// MARK: - Liquid Glass Helper

private extension View {

    @ViewBuilder
    func if_iOS26GlassElseBorderedProminent() -> some View {
        if #available(iOS 26.0, *) {
            self.buttonStyle(.glass)
        } else {
            self.buttonStyle(.borderedProminent)
        }
    }

    @ViewBuilder
    func if_iOS26GlassElsePlain() -> some View {
        if #available(iOS 26.0, *) {
            self.buttonStyle(.glass)
        } else {
            self.buttonStyle(.plain)
        }
    }
}
