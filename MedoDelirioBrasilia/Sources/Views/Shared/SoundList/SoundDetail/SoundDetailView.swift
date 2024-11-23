//
//  SoundDetailView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 04/09/23.
//

import SwiftUI

/// A view that displays the details of a specific sound, including its title, author, statistics, and additional information.
///
/// `SoundDetailView` provides options to play the sound, view author details, and display sound-related statistics.
/// It also supports sending suggestions to update the author name via an email picker.
///
/// - Parameters:
///   - sound: The sound item to be displayed with its details.
///   - openAuthorDetailsAction: A closure triggered to open the author's detail view.
///   - authorId: An optional author ID for deciding if the author's name button should navigate to author details or not. When already opening from author details it should NOT.
struct SoundDetailView: View {

    @StateObject private var viewModel: ViewModel

    @Environment(\.dismiss) var dismiss

    // MARK: - Initializer

    init(
        sound: Sound,
        openAuthorDetailsAction: @escaping (Author) -> Void,
        authorId: String?,
        openReactionAction: @escaping (Reaction) -> Void
    ) {
        self._viewModel = StateObject(
            wrappedValue: ViewModel(
                sound: sound,
                openAuthorDetailsAction: openAuthorDetailsAction,
                authorId: authorId,
                openReactionAction: openReactionAction
            )
        )
    }

    // MARK: - View Body

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    HStack {
                        Spacer()

                        AlbumCoverPlayView(isPlaying: $viewModel.isPlaying)
                            .onTapGesture {
                                viewModel.onPlaySoundSelected()
                            }

                        Spacer()
                    }
                    .padding(.horizontal, .spacing(.medium))

                    TitleAndAuthorSection(
                        soundTitle: viewModel.sound.title,
                        authorName: viewModel.sound.authorName ?? "",
                        authorCanNavigate: viewModel.sound.authorId != viewModel.authorId,
                        authorSelectedAction: { viewModel.onAuthorSelected() },
                        editAuthorSelectedAction: { viewModel.onEditAuthorSelected() }
                    )
                    .padding(.horizontal, .spacing(.medium))

                    StatsSection(
                        stats: viewModel.soundStatistics,
                        retryAction: { Task { await viewModel.onRetryLoadStatisticsSelected() } }
                    )
                    .padding(.horizontal, .spacing(.medium))

                    ReactionsSection(
                        state: viewModel.reactionsState,
                        openReactionAction: { viewModel.onReactionSelected(reaction: $0) },
                        suggestAction: { viewModel.onSuggestAddToReactionSelected() },
                        reloadAction: {
                            Task { await viewModel.onRetryLoadReactionsSelected() }
                        }
                    )

                    InfoSection(sound: viewModel.sound)
                        .padding(.horizontal, .spacing(.medium))

                    Spacer()
                }
                .padding(.vertical, .spacing(.small))
                .navigationTitle("Detalhes do Som")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Fechar") {
                            dismiss()
                        }
                    }
                }
                .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert) {
                    // No buttons
                } message: {
                    Text(viewModel.alertMessage)
                }
                .sheet(isPresented: $viewModel.showSuggestOtherAuthorEmailAppPicker) {
                    EmailAppPickerView(
                        isBeingShown: $viewModel.showSuggestOtherAuthorEmailAppPicker,
                        didCopySupportAddress: $viewModel.didCopySupportAddressOnEmailPicker,
                        subject: String(format: Shared.suggestOtherAuthorNameEmailSubject, viewModel.sound.title),
                        emailBody: String(format: Shared.suggestOtherAuthorNameEmailBody, viewModel.sound.authorName ?? "", viewModel.sound.id)
                    )
                }
                .onChange(of: viewModel.didCopySupportAddressOnEmailPicker) {
                    if $0 {
                        withAnimation {
                            viewModel.showToastView = true
                        }
                        TapticFeedback.success()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                viewModel.showToastView = false
                            }
                        }
                        
                        viewModel.didCopySupportAddressOnEmailPicker = false
                    }
                }
            }
            .overlay {
                if viewModel.showToastView {
                    VStack {
                        Spacer()
                        
                        ToastView(
                            icon: "checkmark",
                            iconColor: .green,
                            text: "E-mail de suporte copiado com sucesso."
                        )
                        .padding(.horizontal)
                        .padding(.bottom, 15)
                    }
                    .transition(.moveAndFade)
                }
            }
            .task {
                await viewModel.onViewLoaded()
            }
        }
    }
}

// MARK: - Subviews

extension SoundDetailView {

    struct TitleAndAuthorSection: View {

        let soundTitle: String
        let authorName: String
        let authorCanNavigate: Bool
        let authorSelectedAction: () -> Void
        let editAuthorSelectedAction: () -> Void

        @Environment(\.colorScheme) var colorScheme

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(soundTitle)
                    .font(.title2)

                Button {
                    authorSelectedAction()
                } label: {
                    HStack(spacing: 8) {
                        Text(authorName)
                        if authorCanNavigate {
                            Image(systemName: "chevron.right")
                        }
                    }
                    .foregroundColor(.gray)
                }
                .padding(.top, 5)
                .padding(.bottom)
                .disabled(!authorCanNavigate)

                Button {
                    editAuthorSelectedAction()
                } label: {
                    Label("Sugerir outro nome de autor", systemImage: "pencil.line")
                }
                .capsule(colored: colorScheme == .dark ? .primary : .gray)
                .padding(.top, 2)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SoundDetailView(
        sound: Sound(
            title: "A gente vai cansando",
            authorName: "Soraya Thronicke",
            description: "meu deus a gente vai cansando sabe"
        ),
        openAuthorDetailsAction: { _ in },
        authorId: nil,
        openReactionAction: { _ in }
    )
}
