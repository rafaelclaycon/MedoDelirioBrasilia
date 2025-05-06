//
//  SearchSuggestionsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 03/05/25.
//

import SwiftUI

struct SearchSuggestionsView: View {

    let recent: [String]? = ["Anitta", "alegria", "pazuello"]
    let trendsService: TrendsServiceProtocol
    let onRecentSelectedAction: (String) -> Void
    let onReactionSelectedAction: (Reaction) -> Void

    @State private var popularContent: LoadingState<[AnyEquatableMedoContent]> = .loading
    @State private var popularReactions: LoadingState<[Reaction]> = .loading

    // MARK: - View Body

    var body: some View {
        VStack(alignment: .leading, spacing: .spacing(.xLarge)) {
            if let recent {
                VStack(alignment: .leading, spacing: .spacing(.medium)) {
                    Text("Pesquisas Recentes")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: .spacing(.medium)) {
                        ForEach(recent, id: \.self) { text in
                            RecentSearchView(text: text)
                                .onTapGesture {
                                    onRecentSelectedAction(text)
                                }
                        }
                    }
                    .padding(.leading, .spacing(.small))
                }
            }

            if case .loaded(let content) = popularContent, !content.isEmpty {
                PopularContentView(content: content)
            }

            if case .loaded(let reactions) = popularReactions, !reactions.isEmpty {
                VStack(alignment: .leading, spacing: .spacing(.small)) {
                    Text("Reações Populares")
                        .font(.headline)

                    ScrollView(.horizontal) {
                        HStack(spacing: .spacing(.medium)) {
                            ForEach(reactions) { reaction in
                                ReactionItem(reaction: reaction)
                                    .frame(width: 220)
                                    .onTapGesture {
                                        onReactionSelectedAction(reaction)
                                    }
                            }
                        }
                    }
                    .scrollBounceBehavior(.basedOnSize)
                }
            }
        }
        .onAppear {
            Task {
                await loadContent()
            }
        }
    }

    // MARK: - Functions

    private func loadContent() async {
        popularContent = .loading
        popularReactions = .loading
        do {
            popularContent = .loaded(try await trendsService.top3Content())
            popularReactions = .loaded(try await trendsService.top3Reactions())
            print("COMUNISTAAAA")
            dump(popularReactions)
        } catch {
            popularContent = .error("")
            popularReactions = .error("")
            debugPrint(error)
        }
    }
}

// MARK: - Subviews

extension SearchSuggestionsView {

    struct RecentSearchView: View {

        let text: String

        var body: some View {
            HStack(spacing: .spacing(.xSmall)) {
                Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")

                Text(text)

                Spacer()
            }
            .padding(.vertical, .spacing(.xSmall))
        }
    }

    struct PopularContentView: View {

        let content: [AnyEquatableMedoContent]

        var body: some View {
            VStack(alignment: .leading, spacing: .spacing(.small)) {
                Text("Conteúdos Populares")
                    .font(.headline)

                ScrollView(.horizontal) {
                    HStack(spacing: .spacing(.medium)) {
                        ForEach(content) { item in
                            PlayableContentView(
                                content: item,
                                favorites: Set<String>(),
                                highlighted: Set<String>(),
                                nowPlaying: Set<String>(),
                                selectedItems: Set<String>(),
                                currentContentListMode: .constant(.regular)
                            )
                            .frame(width: 200)
                        }
                    }
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(alignment: .leading) {
            HStack {
                SearchSuggestionsView(
                    trendsService: TrendsService(
                        database: FakeLocalDatabase(),
                        apiClient: FakeAPIClient(),
                        contentRepository: FakeContentRepository()
                    ),
                    onRecentSelectedAction: { _ in },
                    onReactionSelectedAction: { _ in }
                )

                Spacer()
            }
        }
        .padding(.spacing(.medium))
    }
}
