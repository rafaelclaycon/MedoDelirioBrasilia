//
//  SearchResultsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 20/01/25.
//

import SwiftUI

struct SearchResultsView: View {

    let searchString: String
    let results: SearchResults

    @State private var columns: [GridItem] = [
        GridItem(.flexible(), spacing: .spacing(.small)),
        GridItem(.flexible(), spacing: .spacing(.small))
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: .spacing(.medium), pinnedViews: .sectionHeaders) {
            if let soundsMatchingTitle = results.soundsMatchingTitle {
                Section {
                    ForEach(soundsMatchingTitle) { item in
                        PlayableContentView(
                            content: item,
                            favorites: Set<String>(arrayLiteral: ""),
                            highlighted: Set<String>(arrayLiteral: ""),
                            nowPlaying: Set<String>(arrayLiteral: ""),
                            selectedItems: Set<String>(arrayLiteral: ""),
                            currentContentListMode: .constant(.regular)
                        )
                        .searchCompletion(item)
                    }
                } header: {
                    HeaderView(title: "SONS - CORRESPONDE NO TÍTULO")
                }
            }

            if let soundsMatchingContent = results.soundsMatchingContent {
                Section {
                    ForEach(soundsMatchingContent) { item in
                        ContentWithDescriptionMatch(
                            content: item,
                            highlight: searchString
                        )
                        .searchCompletion(item)
                    }
                } header: {
                    HeaderView(title: "SONS - CORRESPONDE NO CONTEÚDO")
                }
            }

            if let authors = results.authors {
                Section {
                    ForEach(authors) { author in
                        VerticalAuthorView(author: author)
                            .searchCompletion(author)
                    }
                } header: {
                    HeaderView(title: "AUTORES - CORRESPONDE NO NOME")
                }
            }

            if let folders = results.folders {
                Section {
                    ForEach(folders) { folder in
                        FolderView(folder: folder)
                            .searchCompletion(folder)
                    }
                } header: {
                    HeaderView(title: "PASTAS - CORRESPONDE NO NOME")
                }
            }

            if let reactionsMatchingTitle = results.reactionsMatchingTitle {
                Section {
                    ForEach(reactionsMatchingTitle) { reaction in
                        ReactionItem(reaction: reaction)
                            .searchCompletion(reaction)
                    }
                } header: {
                    HeaderView(title: "REAÇÕES - CORRESPONDE NO TÍTULO")
                }
            }

            if let reactionsMatchingFeeling = results.reactionsMatchingFeeling {
                Section {
                    ForEach(reactionsMatchingFeeling) { reaction in
                        ReactionItem(reaction: reaction)
                            .searchCompletion(reaction)
                    }
                } header: {
                    HeaderView(title: "REAÇÕES - EXPRESSA O SENTIMENTO DE \"ALEGRIA\"")
                }
            }
        }
    }
}

// MARK: - Subviews

extension SearchResultsView {

    struct HeaderView: View {

        let title: String

        var body: some View {
            HStack {
                Text(title)
                    .font(.callout)
                    .foregroundStyle(.gray)

                Spacer()
            }
            .background(Color.systemBackground)
        }
    }

    struct ContentWithDescriptionMatch: View {

        let content: AnyEquatableMedoContent
        let highlight: String

        private var text: AttributedString {
            var attributedString = AttributedString(content.description)
            if let range = attributedString.range(of: highlight, options: .caseInsensitive) {
                attributedString[range].foregroundColor = .yellow
            }
            return attributedString
        }

        var body: some View {
            VStack {
                PlayableContentView(
                    content: content,
                    favorites: Set<String>(arrayLiteral: ""),
                    highlighted: Set<String>(arrayLiteral: ""),
                    nowPlaying: Set<String>(arrayLiteral: ""),
                    selectedItems: Set<String>(arrayLiteral: ""),
                    currentContentListMode: .constant(.regular)
                )

                Text("\"\(text)\"")
                    .italic()
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        SearchResultsView(
            searchString: "bolso",
            results: SearchResults(
                soundsMatchingTitle: Sound.sampleSounds.map { AnyEquatableMedoContent($0) },
                soundsMatchingContent: [Sound.sampleBolsoA, Sound.sampleBolsoB].map { AnyEquatableMedoContent($0) },
                authors: [.bozo, .omarAziz],
                folders: [.mockA, .mockB],
                reactionsMatchingTitle: [.viralMock, .choqueMock]
            )
        )
    }
    .padding(.all, .spacing(.medium))
}
