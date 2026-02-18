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

    @State private var isScrubbing: Bool = false
    @State private var scrubValue: TimeInterval = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

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
        }
        .padding(.horizontal, .spacing(.xLarge))
        .presentationDragIndicator(.visible)
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
                .fontWeight(.bold)
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
            Slider(
                value: Binding(
                    get: { isScrubbing ? scrubValue : player.currentTime },
                    set: { newValue in
                        scrubValue = newValue
                    }
                ),
                in: 0...max(player.duration, 1),
                onEditingChanged: { editing in
                    isScrubbing = editing
                    if !editing {
                        player.seek(to: scrubValue)
                    }
                }
            )
            .tint(.primary)

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

// MARK: - Preview

#Preview {
    let player = EpisodePlayer()
    NowPlayingView()
        .environment(player)
}
