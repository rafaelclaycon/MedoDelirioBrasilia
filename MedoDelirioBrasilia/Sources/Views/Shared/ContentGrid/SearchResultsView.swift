//
//  SearchResultsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 20/01/25.
//

import SwiftUI

struct SearchResultsView: View {

    let results: SearchResults

    @State private var columns: [GridItem] = [
        GridItem(.flexible(), spacing: .spacing(.small)),
        GridItem(.flexible(), spacing: .spacing(.small))
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: .spacing(.medium), pinnedViews: .sectionHeaders) {
            if let content = results.content {
                Section {
                    ForEach(content) { item in
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
                    HeaderView(title: "SONS - CORRESPONDÊNCIA NO TÍTULO")
                }
            }

//            if let content = results.content {
//                Section {
//                    ForEach(content) { item in
//                        PlayableContentView(
//                            content: item,
//                            favorites: Set<String>(arrayLiteral: ""),
//                            highlighted: Set<String>(arrayLiteral: ""),
//                            nowPlaying: Set<String>(arrayLiteral: ""),
//                            selectedItems: Set<String>(arrayLiteral: ""),
//                            currentContentListMode: .constant(.regular)
//                        )
//                        .searchCompletion(item)
//                    }
//                } header: {
//                    HeaderView(title: "SONS - CORRESPONDÊNCIA NO CONTEÚDO")
//                }
//            }

            if let authors = results.authors {
                Section {
                    ForEach(authors) { author in
                        VerticalAuthorView(author: author)
                            .searchCompletion(author)
                    }
                } header: {
                    HeaderView(title: "AUTORES")
                }
            }

            if let folders = results.folders {
                Section {
                    ForEach(folders) { folder in
                        FolderView(folder: folder)
                            .searchCompletion(folder)
                    }
                } header: {
                    HeaderView(title: "PASTAS")
                }
            }

            if let reactions = results.reactions {
                Section {
                    ForEach(reactions) { reaction in
                        ReactionItem(reaction: reaction)
                            .searchCompletion(reaction)
                    }
                } header: {
                    HeaderView(title: "REAÇÕES - CORRESPONDE NO TÍTULO")
                }
            }

            if let reactions = results.reactions {
                Section {
                    ForEach(reactions) { reaction in
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
}

// MARK: - Preview

#Preview {
    ScrollView {
        SearchResultsView(
            results: SearchResults(
                content: Sound.sampleSounds.map { AnyEquatableMedoContent($0) },
                authors: [.bozo, .omarAziz],
                folders: [.mockA, .mockB],
                reactions: [.viralMock, .choqueMock]
            )
        )
    }
    .padding(.all, .spacing(.medium))
}
