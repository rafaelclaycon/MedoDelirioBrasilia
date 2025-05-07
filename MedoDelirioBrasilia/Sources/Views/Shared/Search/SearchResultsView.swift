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

    private let itemCountWhenCollapsed: Int = 4

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
                spacing: .spacing(.medium),
                pinnedViews: .sectionHeaders
            ) {
                // MARK: - Sounds

                if let soundsMatchingTitle = results.soundsMatchingTitle, !soundsMatchingTitle.isEmpty {
                    CollapsibleResultSection(
                        items: soundsMatchingTitle,
                        itemCountWhenCollapsed: itemCountWhenCollapsed,
                        headerSymbol: "speaker.wave.3",
                        headerTitle: "Sons",
                        contentView: { item in
                            PlayableContentView(
                                content: item,
                                favorites: Set<String>(arrayLiteral: ""),
                                highlighted: Set<String>(arrayLiteral: ""),
                                nowPlaying: Set<String>(arrayLiteral: ""),
                                selectedItems: Set<String>(arrayLiteral: ""),
                                currentContentListMode: .constant(.regular)
                            )
                        }
                    )
                }

                if let soundsMatchingContent = results.soundsMatchingContent, !soundsMatchingContent.isEmpty {
                    CollapsibleResultSection(
                        items: soundsMatchingContent,
                        itemCountWhenCollapsed: itemCountWhenCollapsed,
                        headerSymbol: "speaker.wave.3",
                        headerTitle: "Conteúdo dos Sons",
                        contentView: { item in
                            ContentWithDescriptionMatch(
                                content: item,
                                highlight: searchString
                            )
                        }
                    )
                }

                // MARK: - Songs

                if let songsMatchingTitle = results.songsMatchingTitle, !songsMatchingTitle.isEmpty {
                    CollapsibleResultSection(
                        items: songsMatchingTitle,
                        itemCountWhenCollapsed: itemCountWhenCollapsed,
                        headerSymbol: "music.quarternote.3",
                        headerTitle: "Músicas",
                        contentView: { item in
                            PlayableContentView(
                                content: item,
                                favorites: Set<String>(arrayLiteral: ""),
                                highlighted: Set<String>(arrayLiteral: ""),
                                nowPlaying: Set<String>(arrayLiteral: ""),
                                selectedItems: Set<String>(arrayLiteral: ""),
                                currentContentListMode: .constant(.regular)
                            )
                        }
                    )
                }

                if let songsMatchingContent = results.songsMatchingContent, !songsMatchingContent.isEmpty {
                    CollapsibleResultSection(
                        items: songsMatchingContent,
                        itemCountWhenCollapsed: itemCountWhenCollapsed,
                        headerSymbol: "music.quarternote.3",
                        headerTitle: "Conteúdo das Músicas",
                        contentView: { item in
                            ContentWithDescriptionMatch(
                                content: item,
                                highlight: searchString
                            )
                        }
                    )
                }

                // MARK: - Authors

                if let authors = results.authors, !authors.isEmpty {
                    CollapsibleResultSection(
                        items: authors,
                        itemCountWhenCollapsed: itemCountWhenCollapsed,
                        headerSymbol: "person.2",
                        headerTitle: "Autores",
                        contentView: { item in
                            VerticalAuthorView(author: item)
                                .onTapGesture {
                                    push(GeneralNavigationDestination.authorDetail(item))
                                }
                        }
                    )
                }

                // MARK: - Folders

                if let folders = results.folders, !folders.isEmpty {
                    CollapsibleResultSection(
                        items: folders,
                        itemCountWhenCollapsed: itemCountWhenCollapsed,
                        headerSymbol: "folder",
                        headerTitle: "Pastas",
                        contentView: { item in
                            FolderView(folder: item)
                                .onTapGesture {
                                    push(GeneralNavigationDestination.folderDetail(item))
                                }
                        }
                    )
                }

                // MARK: - Reactions

                if let reactionsMatchingTitle = results.reactionsMatchingTitle, !reactionsMatchingTitle.isEmpty {
                    CollapsibleResultSection(
                        items: reactionsMatchingTitle,
                        itemCountWhenCollapsed: itemCountWhenCollapsed,
                        headerSymbol: "rectangle.grid.2x2",
                        headerTitle: "Reações",
                        contentView: { item in
                            ReactionItem(reaction: item)
                                .onTapGesture {
                                    push(GeneralNavigationDestination.reactionDetail(item))
                                }
                        }
                    )
                }

                if let reactionsMatchingFeeling = results.reactionsMatchingFeeling, !reactionsMatchingFeeling.isEmpty {
                    CollapsibleResultSection(
                        items: reactionsMatchingFeeling,
                        itemCountWhenCollapsed: itemCountWhenCollapsed,
                        headerSymbol: "theatermasks",
                        headerTitle: "Reações que expressam o sentimento de \"\(searchString)\"",
                        contentView: { item in
                            ReactionItem(reaction: item)
                                .onTapGesture {
                                    push(GeneralNavigationDestination.reactionDetail(item))
                                }
                        }
                    )
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

        let symbol: String
        let title: String
        let resultCount: Int

        private var countText: String {
            resultCount == 1 ? "1 RESULTADO" : "\(resultCount) RESULTADOS"
        }

        var body: some View {
            HStack {
                Image(systemName: symbol)

                Text(title)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)

                Spacer()


                Text(countText)
                    .font(.callout)
                    .foregroundStyle(.gray)
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

    struct CollapsibleResultSection<T: Identifiable, ItemView: View>: View {

        let items: [T]
        let itemCountWhenCollapsed: Int
        let headerSymbol: String
        let headerTitle: String
        let contentView: (T) -> ItemView

        @State private var isCollapsed: Bool = true

        var body: some View {
            Section {
                if isCollapsed {
                    ForEach(items.prefix(itemCountWhenCollapsed)) { item in
                        contentView(item)
                    }
                } else {
                    ForEach(items) { item in
                        contentView(item)
                    }
                }
            } header: {
                HeaderView(
                    symbol: headerSymbol,
                    title: headerTitle,
                    resultCount: items.count
                )
            } footer: {
                if items.count > itemCountWhenCollapsed && isCollapsed {
                    Button {
                        withAnimation {
                            isCollapsed.toggle()
                        }
                    } label: {
                        HStack {
                            Spacer()
                            Text("Ver Tudo")
                                .bold()
                            Spacer()
                        }
                    }
                    .largeRoundedRectangleBordered(colored: .green)
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("No Results") {
    GeometryReader { geometry in
        ScrollView {
            SearchResultsView(
                searchString: "Bolsorrrgnnn",
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
                searchString: "Bolso",
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
