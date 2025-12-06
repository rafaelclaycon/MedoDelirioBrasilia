//
//  StoriesView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 20/10/24.
//

import SwiftUI

struct StoriesView: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = ViewModel()
    
    @State private var currentStoryIndex: Int = 0
    @State private var progress: CGFloat = 0.0
    @State private var isPaused: Bool = false
    @State private var timerActive: Bool = false
    @State private var showIntro: Bool = true
    @State private var isMuted: Bool = false
    
    private let progressUpdateInterval: TimeInterval = 0.05
    private let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ClassicRetroView.LoadingView()
            } else if showIntro {
                // Surprise intro animation
                SurpriseIntroView {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showIntro = false
                    }
                    startTimer()
                }
            } else if !viewModel.stories.isEmpty {
                // Background
                currentStory.backgroundColor.view()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Progress indicators at top
                    StoryProgressIndicator(
                        numberOfStories: viewModel.stories.count,
                        currentStoryIndex: currentStoryIndex,
                        currentProgress: progress
                    )
                    .zIndex(100)
                    
                    // Story content
                    ZStack {
                        storyContentView(for: currentStoryIndex)
                    }
                    .id(currentStoryIndex)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                // Tap zones for navigation (edge strips only)
                .overlay {
                    HStack(spacing: 0) {
                        // Left edge - previous story
                        Color.clear
                            .contentShape(Rectangle())
                            .frame(width: 60)
                            .onTapGesture {
                                goToPreviousStory()
                            }
                        
                        Spacer()
                        
                        // Right edge - next story
                        Color.clear
                            .contentShape(Rectangle())
                            .frame(width: 60)
                            .onTapGesture {
                                goToNextStory()
                            }
                    }
                }
                
                // Close button (after tap zones so it's on top)
                .overlay(alignment: .topTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .padding(.trailing, 16)
                    .padding(.top, 16)
                }
                
                // Mute button (bottom left) - only on audio stories
                .overlay(alignment: .bottomLeading) {
                    if currentStoryPlaysAudio {
                        Button {
                            isMuted.toggle()
                            if isMuted {
                                // Stop any currently playing audio
                                AudioPlayer.shared?.cancel()
                            }
                        } label: {
                            Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                                .contentShape(Rectangle())
                        }
                        .padding(.leading, 16)
                        .padding(.bottom, 40)
                    }
                }
                
                // Long press to pause
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.2)
                        .onChanged { _ in
                            pauseTimer()
                        }
                        .onEnded { _ in
                            resumeTimer()
                        }
                )
            }
        }
        .statusBar(hidden: true)
        .task {
            await viewModel.loadData()
        }
        .onDisappear {
            stopTimer()
            AudioPlayer.shared?.cancel()
        }
        .onReceive(timer) { _ in
            guard timerActive && !isPaused else { return }
            
            let increment = CGFloat(progressUpdateInterval / currentStory.duration)
            progress += increment
            
            if progress >= 1.0 {
                goToNextStory()
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    // Dismiss if swiped down significantly
                    if value.translation.height > 100 {
                        dismiss()
                    }
                }
        )
    }
    
    // MARK: - Computed Properties
    
    private var currentStory: Story {
        guard currentStoryIndex < viewModel.stories.count else {
            return viewModel.stories.last ?? Story(id: "default")
        }
        return viewModel.stories[currentStoryIndex]
    }
    
    private var currentStoryPlaysAudio: Bool {
        let audioStoryIds = ["topSound1", "topSound2", "topSound3"]
        return audioStoryIds.contains(currentStory.id)
    }
    
    // MARK: - Story Content Views
    
    @ViewBuilder
    private func storyContentView(for index: Int) -> some View {
        if index < viewModel.stories.count {
            let storyId = viewModel.stories[index].id
            
            switch storyId {
            case "welcome":
                WelcomeStory()
                
            case "topSound1":
                if let sound = viewModel.topSound(at: 0) {
                    TopSoundStory(
                        rankNumber: 1,
                        soundId: sound.contentId,
                        soundName: sound.contentName,
                        authorName: sound.contentAuthorName,
                        shareCount: sound.shareCount,
                        isMuted: $isMuted
                    )
                }
                
            case "topSound2":
                if let sound = viewModel.topSound(at: 1) {
                    TopSoundStory(
                        rankNumber: 2,
                        soundId: sound.contentId,
                        soundName: sound.contentName,
                        authorName: sound.contentAuthorName,
                        shareCount: sound.shareCount,
                        isMuted: $isMuted
                    )
                }
                
            case "topSound3":
                if let sound = viewModel.topSound(at: 2) {
                    TopSoundStory(
                        rankNumber: 3,
                        soundId: sound.contentId,
                        soundName: sound.contentName,
                        authorName: sound.contentAuthorName,
                        shareCount: sound.shareCount,
                        isMuted: $isMuted
                    )
                }
                
            case "stats":
                StatsStory(
                    totalShares: viewModel.totalShareCount,
                    uniqueSounds: viewModel.totalUniqueSoundsShared,
                    favoriteDay: viewModel.mostCommonShareDay
                )
                
            case "share":
                ShareStory(
                    topAuthor: viewModel.topAuthor,
                    topSounds: viewModel.topSounds,
                    totalShares: viewModel.totalShareCount,
                    favoriteDay: viewModel.mostCommonShareDay
                )
                
            default:
                EmptyView()
            }
        }
    }
    
    // MARK: - Timer Management
    
    private func startTimer() {
        progress = 0.0
        timerActive = true
    }
    
    private func stopTimer() {
        timerActive = false
    }
    
    private func pauseTimer() {
        isPaused = true
    }
    
    private func resumeTimer() {
        isPaused = false
    }
    
    // MARK: - Navigation
    
    private func goToNextStory() {
        // Stop any currently playing audio before changing stories
        AudioPlayer.shared?.cancel()
        
        if currentStoryIndex < viewModel.stories.count - 1 {
            currentStoryIndex += 1
            progress = 0.0
        } else {
            // Reached the end
            stopTimer()
            dismiss()
        }
    }
    
    private func goToPreviousStory() {
        // Stop any currently playing audio before changing stories
        AudioPlayer.shared?.cancel()
        
        if currentStoryIndex > 0 {
            currentStoryIndex -= 1
            progress = 0.0
        }
    }
}

// MARK: - Preview

#Preview {
    StoriesView()
}
