//
//  SidecastClipPreviewView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 25/02/26.
//

import AVKit
import SwiftUI

struct SidecastClipPreviewView: View {

    let config: SidecastClipGenerator.Configuration

    @State private var videoURL: URL?
    @State private var player: AVPlayer?
    @State private var generationPhase: SidecastClipGenerator.GenerationPhase?
    @State private var error: Error?
    @State private var isShowingShareSheet: Bool = false
    @State private var generationTask: Task<Void, Never>?

    var body: some View {
        Group {
            if let player {
                videoPreview(player: player)
            } else if let error {
                errorView(error: error)
            } else {
                loadingView
            }
        }
        .navigationTitle("Pré-visualização")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            generationTask = Task { await generateClip() }
        }
        .onDisappear {
            generationTask?.cancel()
            generationTask = nil
            player?.pause()
        }
        .sheet(isPresented: $isShowingShareSheet) {
            if let videoURL {
                ActivityViewController(activityItems: [videoURL])
            }
        }
    }

    // MARK: - Subviews

    private func videoPreview(player: AVPlayer) -> some View {
        let videoSize = config.shareMode.videoSize ?? CGSize(width: 9, height: 16)
        let aspectRatio = videoSize.width / videoSize.height

        return VStack(spacing: .spacing(.xxLarge)) {
            Spacer()

            VideoPlayer(player: player)
                .aspectRatio(aspectRatio, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            shareButton

            Spacer()
        }
        .padding(.horizontal, .spacing(.xLarge))
        .padding(.vertical, .spacing(.large))
    }

    private func errorView(error: Error) -> some View {
        ContentUnavailableView(
            "Erro ao gerar clipe",
            systemImage: "exclamationmark.triangle",
            description: Text(error.localizedDescription)
        )
    }

    private var loadingView: some View {
        VStack(spacing: .spacing(.medium)) {
            ProgressView()
                .controlSize(.large)

            Text(generationPhase?.rawValue ?? "Preparando…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.2), value: generationPhase)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var shareButton: some View {
        Button {
            isShowingShareSheet = true
        } label: {
            HStack {
                Spacer()
                Label("Compartilhar Clipe", systemImage: "square.and.arrow.up")
                    .font(.headline)
                Spacer()
            }
        }
        .sidecastButtonStyle()
    }

    // MARK: - Generation

    private func generateClip() async {
        do {
            let url = try await SidecastClipGenerator.generate(
                config: config
            ) { phase in
                Task { @MainActor in
                    generationPhase = phase
                }
            }
            videoURL = url
            player = AVPlayer(url: url)
        } catch is CancellationError {
            // Task cancelled
        } catch {
            guard !Task.isCancelled else { return }
            self.error = error
        }
    }
}

// MARK: - Shared Button Style

extension View {

    @ViewBuilder
    func sidecastButtonStyle() -> some View {
        if #available(iOS 26, *) {
            self
                .controlSize(.large)
                .buttonStyle(.glassProminent)
                .tint(.orange)
        } else {
            self
                .buttonStyle(.borderedProminent)
                .tint(.orange)
        }
    }
}
