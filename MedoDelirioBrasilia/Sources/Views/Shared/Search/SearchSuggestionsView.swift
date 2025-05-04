//
//  SearchSuggestionsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 03/05/25.
//

import SwiftUI

struct SearchSuggestionsView: View {

    let recent: [String]? = ["Anitta", "alegria", "pazuello"]
    let onRecentSelectedAction: (String) -> Void

    let popularContent: [AnyEquatableMedoContent]?

    let popularReactions: [Reaction]?
    let onReactionSelectedAction: (Reaction) -> Void

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

            if let popularContent {
                VStack(alignment: .leading, spacing: .spacing(.small)) {
                    Text("Conteúdos Populares")
                        .font(.headline)

                    ScrollView(.horizontal) {
                        HStack(spacing: .spacing(.medium)) {
                            ForEach(popularContent) { content in
                                PlayableContentView(
                                    content: content,
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

            if let popularReactions {
                VStack(alignment: .leading, spacing: .spacing(.small)) {
                    Text("Reações Populares")
                        .font(.headline)

                    ScrollView(.horizontal) {
                        HStack(spacing: .spacing(.medium)) {
                            ForEach(popularReactions) { reaction in
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
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(alignment: .leading) {
            HStack {
                SearchSuggestionsView(
                    onRecentSelectedAction: { _ in },
                    popularContent: Sound.sampleSounds.prefix(3).map { AnyEquatableMedoContent($0) },
                    popularReactions: [Reaction.acidMock, Reaction.classicsMock, Reaction.frustrationMock],
                    onReactionSelectedAction: { _ in }
                )

                Spacer()
            }
        }
        .padding(.spacing(.medium))
    }
}
