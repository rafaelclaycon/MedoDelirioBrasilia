//
//  NowPlayingView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 17/02/26.
//

import SwiftUI

/// Full now-playing screen presented as a sheet from the bottom accessory.
struct NowPlayingView: View {

    @Environment(EpisodePlayer.self) private var player
    @Environment(EpisodeBookmarkStore.self) private var bookmarkStore

    @State private var isScrubbing: Bool = false
    @State private var scrubValue: TimeInterval = 0
    @State private var toast: Toast?
    @State private var editingBookmark: EpisodeBookmark?

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: .spacing(.xLarge))

                artwork

                Spacer()
                    .frame(height: .spacing(.xxLarge))

                episodeInfo

                Spacer()
                    .frame(height: .spacing(.xxLarge))

                progressSection

                Spacer()
                    .frame(height: .spacing(.xLarge))

                playbackControls

                Spacer()
                    .frame(height: .spacing(.medium))

                HStack(spacing: .spacing(.medium)) {
                    GlassButton(
                        symbol: "bookmark.fill",
                        title: "Marcar Esse Ponto",
                        color: .rubyRed,
                        lightModeLabelColor: .rubyRed,
                        action: {
                            guard let episodeId = player.currentEpisode?.id else { return }
                            bookmarkStore.addBookmark(episodeId: episodeId, timestamp: player.currentTime)
                            toast = Toast(message: "Marcador Adicionado", type: .success)
                        }
                    )

                    // TODO: Adicionar Nota button (hidden for now)
                }

                Spacer()
                    .frame(height: .spacing(.xLarge))

                bookmarkList
            }
            .padding(.horizontal, .spacing(.xLarge))
        }
        .presentationDragIndicator(.visible)
        .toast($toast)
        .sheet(item: $editingBookmark) { bookmark in
            BookmarkEditView(bookmark: bookmark)
                .environment(bookmarkStore)
        }
        .onAppear {
            if player.pendingRemoteBookmark {
                player.pendingRemoteBookmark = false
                toast = Toast(message: "Marcador Adicionado", type: .success)
            }
        }
    }

    // MARK: - Artwork

    private var artwork: some View {
        AsyncImage(url: player.currentEpisode?.imageURL) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case .failure:
                artworkPlaceholder
            case .empty:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            @unknown default:
                artworkPlaceholder
            }
        }
        .frame(maxWidth: 300, maxHeight: 300)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 8, y: 4)
    }

    private var artworkPlaceholder: some View {
        ZStack {
            Color(.tertiarySystemFill)
            Image(systemName: "radio")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Episode Info

    private var episodeInfo: some View {
        VStack(spacing: .spacing(.xxxSmall)) {
            Text(player.currentEpisode?.title ?? "")
                .font(.title2)
                .fontDesign(.serif)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            if let pubDate = player.currentEpisode?.pubDate {
                Text(pubDate, format: .dateTime.day().month(.wide).year())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Progress

    private var progressSection: some View {
        VStack(spacing: .spacing(.xxxSmall)) {
            scrubberWithMarkers

            HStack {
                Text(Self.formatTime(isScrubbing ? scrubValue : player.currentTime))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()

                Spacer()

                Text("-" + Self.formatTime(player.duration - (isScrubbing ? scrubValue : player.currentTime)))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
        }
    }

    private static let trackHeight: CGFloat = 4
    private static let thumbSize: CGFloat = 14
    private static let trackColor = Color.darkerGreen
    private static let trackBgColor = Color(.systemGray4)

    private var scrubberWithMarkers: some View {
        GeometryReader { geometry in
            let totalDuration = max(player.duration, 1)
            let currentValue = isScrubbing ? scrubValue : player.currentTime
            let fraction = CGFloat(currentValue / totalDuration)
            let thumbX = fraction * geometry.size.width

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Self.trackBgColor)
                    .frame(height: Self.trackHeight)

                Capsule()
                    .fill(Self.trackColor)
                    .frame(width: max(thumbX, 0), height: Self.trackHeight)

                ForEach(currentBookmarks) { bookmark in
                    let bFraction = bookmark.timestamp / totalDuration
                    let bX = geometry.size.width * bFraction

                    Capsule()
                        .fill(Color.rubyRed)
                        .frame(width: 3, height: Self.trackHeight + 12)
                        .offset(x: bX - 1.5)
                }

                Circle()
                    .fill(Self.trackColor)
                    .frame(width: Self.thumbSize, height: Self.thumbSize)
                    .offset(x: thumbX - Self.thumbSize / 2)
            }
            .frame(height: Self.thumbSize)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if !isScrubbing { isScrubbing = true }
                        let clamped = min(max(value.location.x, 0), geometry.size.width)
                        scrubValue = TimeInterval(clamped / geometry.size.width) * totalDuration
                    }
                    .onEnded { _ in
                        isScrubbing = false
                        player.seek(to: scrubValue)
                    }
            )
        }
        .frame(height: Self.thumbSize)
    }

    // MARK: - Playback Controls

    private var playbackControls: some View {
        HStack(spacing: .spacing(.xxxLarge)) {
            Button {
                player.skipBackward()
            } label: {
                Image(systemName: "gobackward.15")
                    .font(.title)
                    .fontWeight(.medium)
            }
            .buttonStyle(.plain)

            Button {
                player.togglePlayPause()
            } label: {
                Image(systemName: player.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 64))
            }
            .buttonStyle(.plain)

            Button {
                player.skipForward()
            } label: {
                Image(systemName: "goforward.30")
                    .font(.title)
                    .fontWeight(.medium)
            }
            .buttonStyle(.plain)
        }
        .foregroundStyle(.primary)
    }

    // MARK: - Bookmark List

    private var currentBookmarks: [EpisodeBookmark] {
        guard let episodeId = player.currentEpisode?.id else { return [] }
        return bookmarkStore.bookmarks(for: episodeId)
    }

    @ViewBuilder
    private var bookmarkList: some View {
        let bookmarks = currentBookmarks
        if !bookmarks.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                Text("Marcadores")
                    .font(.headline)
                    .padding(.bottom, .spacing(.small))

                ForEach(Array(bookmarks.enumerated()), id: \.element.id) { index, bookmark in
                    bookmarkRow(bookmark)

                    if index < bookmarks.count - 1 {
                        Divider()
                    }
                }
            }
            .padding(.bottom, .spacing(.xLarge))
        }
    }

    private func bookmarkRow(_ bookmark: EpisodeBookmark) -> some View {
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
                player.seek(to: bookmark.timestamp)
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

    // MARK: - Helpers

    /// Formats a `TimeInterval` to `M:SS` or `H:MM:SS`.
    static func formatTime(_ time: TimeInterval) -> String {
        let totalSeconds = max(Int(time), 0)
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

// MARK: - Subviews

extension NowPlayingView {

    struct GlassButton: View {

        let symbol: String
        let title: String
        let color: Color
        let lightModeLabelColor: Color
        let action: () -> Void

        @Environment(\.colorScheme) var colorScheme

        var body: some View {
            if #available(iOS 26, *) {
                Label(title, systemImage: symbol)
                    .font(.subheadline)
                    .fontWeight(.regular)
                    .foregroundStyle(colorScheme == .dark ? .white : lightModeLabelColor)
                    .padding(.vertical, .spacing(.small))
                    .padding(.horizontal, .spacing(.medium))
                    .glassEffect(
                        .regular.tint(
                            colorScheme == .dark ? color.opacity(0.3) : color.opacity(0.1)
                        ).interactive()
                    )
                    //.contentShape(Rectangle())
                    .onTapGesture {
                        action()
                    }
            } else {
                Button {
                    action()
                } label: {
                    Label(title, systemImage: symbol)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(color)
                }
                .buttonStyle(.bordered)
                .tint(color)
            }
        }
    }
}

// MARK: - Liquid Glass Helper

private extension View {

    @ViewBuilder
    func if_iOS26GlassElsePlain() -> some View {
        if #available(iOS 26.0, *) {
            self.buttonStyle(.glass)
        } else {
            self.buttonStyle(.plain)
        }
    }
}

// MARK: - Preview

#Preview {
    let player = EpisodePlayer()
    NowPlayingView()
        .environment(player)
        .environment(EpisodeBookmarkStore())
}
