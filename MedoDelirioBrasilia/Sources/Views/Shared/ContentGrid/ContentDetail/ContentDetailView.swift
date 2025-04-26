//
//  ContentDetailView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 04/09/23.
//

import SwiftUI

/// A view that displays the details of a specific sound, including its title, author, statistics, and additional information.
///
/// `ContentDetailView` provides options to play the sound, view author details, and display sound-related statistics.
/// It also supports sending suggestions to update the author name via an email picker.
///
/// - Parameters:
///   - content: The content item to be displayed with its details.
///   - openAuthorDetailsAction: A closure triggered to open the author's detail view.
///   - authorId: An optional author ID for deciding if the author's name button should navigate to author details or not. When already opening from author details it should NOT.
struct ContentDetailView: View {

    @StateObject private var viewModel: ViewModel

    @Environment(\.dismiss) var dismiss

    // MARK: - Initializer

    init(
        content: AnyEquatableMedoContent,
        openAuthorDetailsAction: @escaping (Author) -> Void,
        authorId: String?,
        openReactionAction: @escaping (Reaction) -> Void,
        reactionId: String?,
        dismissAction: @escaping () -> Void
    ) {
        self._viewModel = StateObject(
            wrappedValue: ViewModel(
                content: content,
                openAuthorDetailsAction: openAuthorDetailsAction,
                authorId: authorId,
                openReactionAction: openReactionAction,
                reactionId: reactionId,
                dismissAction: dismissAction
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
                        type: viewModel.content.type,
                        title: viewModel.content.title,
                        authorName: viewModel.content.subtitle,
                        authorCanNavigate: (viewModel.content.authorId != viewModel.authorId) && (viewModel.content.type == .sound),
                        authorSelectedAction: { viewModel.onAuthorSelected() },
                        editAuthorSelectedAction: { viewModel.onEditAuthorSelected() }
                    )
                    .padding(.horizontal, .spacing(.medium))

                    StatsSection(
                        stats: viewModel.soundStatistics,
                        retryAction: { Task { await viewModel.onRetryLoadStatisticsSelected() } }
                    )
                    .padding(.horizontal, .spacing(.medium))

                    if viewModel.content.type == .sound {
                        ReactionsSection(
                            state: viewModel.reactionsState,
                            openReactionAction: { viewModel.onReactionSelected(reaction: $0) },
                            suggestAction: { viewModel.onSuggestAddToReactionSelected() },
                            reloadAction: {
                                Task { await viewModel.onRetryLoadReactionsSelected() }
                            }
                        )
                    }

                    InfoSection(
                        content: viewModel.content,
                        idSelectedAction: { viewModel.onSoundIdSelected() }
                    )
                    .padding(.horizontal, .spacing(.medium))

                    Spacer()
                }
                .padding(.vertical, .spacing(.small))
                .navigationTitle("Detalhes \(viewModel.content.type == .sound ? "do Som" : "da Música")")
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
                .sheet(isPresented: $viewModel.showAuthorSuggestionEmailAppPicker) {
                    EmailAppPickerView(
                        isBeingShown: $viewModel.showAuthorSuggestionEmailAppPicker,
                        toast: $viewModel.toast,
                        subject: String(format: Shared.suggestOtherAuthorNameEmailSubject, viewModel.content.title),
                        emailBody: String(format: Shared.suggestOtherAuthorNameEmailBody, viewModel.content.subtitle, viewModel.content.id)
                    )
                }
                .sheet(isPresented: $viewModel.showReactionSuggestionEmailAppPicker) {
                    EmailAppPickerView(
                        isBeingShown: $viewModel.showReactionSuggestionEmailAppPicker,
                        toast: $viewModel.toast,
                        subject: String(format: "Sugestão Para Adicionar '%@' a Uma Reação", viewModel.content.title),
                        emailBody: String(format: "As Reações expressam emoções, acontecimentos ou personalidades. Qual o nome da Reação nova ou existente na qual você acha que esse som se encaixa?")
                    )
                }
            }
            .toast($viewModel.toast)
            .task {
                await viewModel.onViewLoaded()
            }
        }
    }
}

// MARK: - Subviews

extension ContentDetailView {

    struct TitleAndAuthorSection: View {

        let type: MediaType
        let title: String
        let authorName: String
        let authorCanNavigate: Bool
        let authorSelectedAction: () -> Void
        let editAuthorSelectedAction: () -> Void

        @Environment(\.colorScheme) var colorScheme

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
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

                if type == .sound {
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
}

// MARK: - Preview

#Preview {
    ContentDetailView(
        content: AnyEquatableMedoContent(
            Sound(
                title: "A gente vai cansando",
                authorName: "Soraya Thronicke",
                description: "meu deus a gente vai cansando sabe"
            )
        ),
        openAuthorDetailsAction: { _ in },
        authorId: nil,
        openReactionAction: { _ in },
        reactionId: nil,
        dismissAction: {}
    )
}
