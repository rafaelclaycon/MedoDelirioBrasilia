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
    let containerWidth: CGFloat

    @State private var columns: [GridItem] = []

    // MARK: - Environment

    @Environment(\.sizeCategory) private var sizeCategory
    @Environment(\.push) private var push

    // MARK: - View Body

    var body: some View {
        if results.noResults {
            NoSearchResultsView(searchText: searchString)
        } else {
            LazyVGrid(
                columns: columns,
                spacing: .spacing(.small),
                pinnedViews: .sectionHeaders
            ) {
                if let soundsMatchingTitle = results.soundsMatchingTitle, !soundsMatchingTitle.isEmpty {
                    Section {
                        ForEach(soundsMatchingTitle.prefix(4)) { item in
                            PlayableContentView(
                                content: item,
                                favorites: Set<String>(arrayLiteral: ""),
                                highlighted: Set<String>(arrayLiteral: ""),
                                nowPlaying: Set<String>(arrayLiteral: ""),
                                selectedItems: Set<String>(arrayLiteral: ""),
                                currentContentListMode: .constant(.regular)
                            )
                        }
                    } header: {
                        HeaderView(title: "SONS QUE CORRESPONDEM NO TÍTULO (\(soundsMatchingTitle.count))")
                    } footer: {
                        Button {
                            print("Tapped")
                        } label: {
                            HStack {
                                Spacer()
                                Text("Ver Todos")
                                Spacer()
                            }
                        }
                    }
                }

                if let soundsMatchingContent = results.soundsMatchingContent, !soundsMatchingContent.isEmpty {
                    Section {
                        ForEach(soundsMatchingContent.prefix(4)) { item in
                            ContentWithDescriptionMatch(
                                content: item,
                                highlight: searchString
                            )
                        }
                    } header: {
                        HeaderView(title: "SONS QUE CORRESPONDEM NO CONTEÚDO (\(soundsMatchingContent.count))")
                    }
                }

                if let songsMatchingTitle = results.songsMatchingTitle, !songsMatchingTitle.isEmpty {
                    Section {
                        ForEach(songsMatchingTitle.prefix(4)) { item in
                            PlayableContentView(
                                content: item,
                                favorites: Set<String>(arrayLiteral: ""),
                                highlighted: Set<String>(arrayLiteral: ""),
                                nowPlaying: Set<String>(arrayLiteral: ""),
                                selectedItems: Set<String>(arrayLiteral: ""),
                                currentContentListMode: .constant(.regular)
                            )
                        }
                    } header: {
                        HeaderView(title: "MÚSICAS QUE CORRESPONDEM NO TÍTULO (\(songsMatchingTitle.count))")
                    }
                }

                if let songsMatchingContent = results.songsMatchingContent, !songsMatchingContent.isEmpty {
                    Section {
                        ForEach(songsMatchingContent.prefix(4)) { item in
                            ContentWithDescriptionMatch(
                                content: item,
                                highlight: searchString
                            )
                        }
                    } header: {
                        HeaderView(title: "MÚSICAS QUE CORRESPONDEM NO CONTEÚDO (\(songsMatchingContent.count))")
                    }
                }

                if let authors = results.authors, !authors.isEmpty {
                    Section {
                        ForEach(authors) { author in
                            VerticalAuthorView(author: author)
                                .onTapGesture {
                                    push(GeneralNavigationDestination.authorDetail(author))
                                }
                        }
                    } header: {
                        HeaderView(title: "AUTORES QUE CORRESPONDEM NO NOME (\(authors.count))")
                    }
                }

                if let folders = results.folders, !folders.isEmpty {
                    Section {
                        ForEach(folders) { folder in
                            FolderView(folder: folder)
                        }
                    } header: {
                        HeaderView(title: "PASTAS QUE CORRESPONDEM NO NOME (\(folders.count))")
                    }
                }

                if let reactionsMatchingTitle = results.reactionsMatchingTitle, !reactionsMatchingTitle.isEmpty {
                    Section {
                        ForEach(reactionsMatchingTitle) { reaction in
                            ReactionItem(reaction: reaction)
                        }
                    } header: {
                        HeaderView(title: "REAÇÕES QUE CORRESPONDEM NO TÍTULO (\(reactionsMatchingTitle.count))")
                    }
                }

                if let reactionsMatchingFeeling = results.reactionsMatchingFeeling, !reactionsMatchingFeeling.isEmpty {
                    Section {
                        ForEach(reactionsMatchingFeeling) { reaction in
                            ReactionItem(reaction: reaction)
                        }
                    } header: {
                        HeaderView(title: "REAÇÕES QUE EXPRESSAM O SENTIMENTO DE \"\(searchString.uppercased())\" (\(reactionsMatchingFeeling.count))")
                    }
                }
            }
            .onAppear {
                updateGridLayout()
            }
            .onChange(of: containerWidth) {
                updateGridLayout()
            }
        }
    }

    // MARK: - Functions

    private func updateGridLayout() {
        columns = GridHelper.adaptableColumns(
            listWidth: containerWidth,
            sizeCategory: sizeCategory,
            spacing: .spacing(.small)
        )
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
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)

                Spacer()
            }
            .padding(.vertical, .spacing(.xSmall))
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
                attributedString[range].font = .headline
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
                    .foregroundStyle(.gray)

                Spacer()
            }
        }
    }
}

// MARK: - Preview

#Preview("No Results") {
    GeometryReader { geometry in
        ScrollView {
            SearchResultsView(
                searchString: "bolsorrrgnnn",
                results: SearchResults(),
                containerWidth: geometry.size.width
            )
            .padding(.all, .spacing(.medium))
        }
    }
}

#Preview("Complete") {
    GeometryReader { geometry in
        ScrollView {
            SearchResultsView(
                searchString: "bolso",
                results: SearchResults(
                    soundsMatchingTitle: Sound.sampleSounds.map { AnyEquatableMedoContent($0) },
                    soundsMatchingContent: [Sound.sampleBolsoA, Sound.sampleBolsoB].map { AnyEquatableMedoContent($0) },
                    authors: [.bozo, .omarAziz],
                    folders: [.mockA, .mockB],
                    reactionsMatchingTitle: [.viralMock, .choqueMock],
                    reactionsMatchingFeeling: [.viralMock]
                ),
                containerWidth: geometry.size.width
            )
            .padding(.all, .spacing(.medium))
        }
    }
}
