//
//  SearchResultsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 20/01/25.
//

import SwiftUI

struct SearchResultsView: View {

    @State var playable: PlayableContentState

    let searchString: String
    let results: SearchResults
    let containerWidth: CGFloat
    var toast: Binding<Toast?>
    var menuOptions: [ContextMenuSection]

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
                spacing: .spacing(.medium)
            ) {
                // MARK: - Sounds

                if let soundsMatchingTitle = results.soundsMatchingTitle, !soundsMatchingTitle.isEmpty {
                    CollapsibleResultSection(
                        items: soundsMatchingTitle,
                        itemCountWhenCollapsed: itemCountWhenCollapsed,
                        headerSymbol: "headphones",
                        headerTitle: "Vírgulas",
                        searchString: searchString,
                        contentView: { item in
                            PlayableContentView(
                                content: item,
                                favorites: playable.favoritesKeeper,
                                highlighted: Set<String>(arrayLiteral: ""),
                                nowPlaying: playable.nowPlayingKeeper,
                                selectedItems: Set<String>(arrayLiteral: ""),
                                currentContentListMode: .constant(.regular)
                            )
                            .contentShape(
                                .contextMenuPreview,
                                RoundedRectangle(cornerRadius: .spacing(.large), style: .continuous)
                            )
                            .onTapGesture {
                                onContentSelected(item, loadedContent: soundsMatchingTitle)
                            }
                            .contextMenu {
                                contextMenuOptionsView(
                                    content: item,
                                    menuOptions: menuOptions,
                                    favorites: playable.favoritesKeeper,
                                    loadedContent: soundsMatchingTitle
                                )
                            }
                        }
                    )
                }

                if let soundsMatchingContent = results.soundsMatchingContent, !soundsMatchingContent.isEmpty {
                    CollapsibleResultSection(
                        items: soundsMatchingContent,
                        itemCountWhenCollapsed: itemCountWhenCollapsed,
                        headerSymbol: "headphones",
                        headerTitle: "Conteúdo das Vírgulas",
                        searchString: searchString,
                        contentView: { item in
                            ContentWithDescriptionMatch(
                                content: item,
                                highlight: searchString,
                                playable: playable
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
                        searchString: searchString,
                        contentView: { item in
                            PlayableContentView(
                                content: item,
                                favorites: playable.favoritesKeeper,
                                highlighted: Set<String>(arrayLiteral: ""),
                                nowPlaying: playable.nowPlayingKeeper,
                                selectedItems: Set<String>(arrayLiteral: ""),
                                currentContentListMode: .constant(.regular)
                            )
                            .onTapGesture {
                                onContentSelected(item, loadedContent: songsMatchingTitle)
                            }
                        }
                    )
                }

                if let songsMatchingContent = results.songsMatchingContent, !songsMatchingContent.isEmpty {
                    CollapsibleResultSection(
                        items: songsMatchingContent,
                        itemCountWhenCollapsed: itemCountWhenCollapsed,
                        headerSymbol: "music.quarternote.3",
                        headerTitle: "Conteúdo das Músicas",
                        searchString: searchString,
                        contentView: { item in
                            ContentWithDescriptionMatch(
                                content: item,
                                highlight: searchString,
                                playable: playable
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
                        searchString: searchString,
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
                        searchString: searchString,
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
                        searchString: searchString,
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
                        searchString: searchString,
                        contentView: { item in
                            ReactionItem(reaction: item)
                                .onTapGesture {
                                    push(GeneralNavigationDestination.reactionDetail(item))
                                }
                        }
                    )
                }
            }
            .playableContentUI(
                state: playable,
                toast: toast,
                onAuthorSelected: { author in
                    push(GeneralNavigationDestination.authorDetail(author))
                },
                onReactionSelected: { reaction in
                    push(GeneralNavigationDestination.reactionDetail(reaction))
                }
            )
            .onAppear {
                playable.onViewAppeared()
                updateGridLayout()
            }
            .onChange(of: containerWidth) {
                updateGridLayout()
            }
        }
    }

    // MARK: - Actions

    private func onContentSelected(
        _ content: AnyEquatableMedoContent,
        loadedContent: [AnyEquatableMedoContent]
    ) {
        if playable.nowPlayingKeeper.contains(content.id) {
            AudioPlayer.shared?.togglePlay()
            playable.nowPlayingKeeper.removeAll()
        } else {
            playable.play(content)
        }
    }

    // MARK: - Subviews

    @MainActor @ViewBuilder
    private func contextMenuOptionsView(
        content: AnyEquatableMedoContent,
        menuOptions: [ContextMenuSection],
        favorites: Set<String>,
        loadedContent: [AnyEquatableMedoContent]
    ) -> some View {
        // Sharing section
        Section {
            Button {
                playable.share(content: content)
            } label: {
                Label(Shared.shareSoundButtonText, systemImage: "square.and.arrow.up")
            }

            Button {
                playable.openShareAsVideoModal(for: content)
            } label: {
                Label(Shared.shareAsVideoButtonText, systemImage: "film")
            }
        }

        // Organizing section
        Section {
            Button {
                playable.toggleFavorite(content.id)
            } label: {
                Label(
                    favorites.contains(content.id) ? Shared.removeFromFavorites : Shared.addToFavorites,
                    systemImage: favorites.contains(content.id) ? "star.slash" : "star"
                )
            }

            Button {
                playable.addToFolder(content)
            } label: {
                Label(Shared.addToFolderButtonText, systemImage: "folder.badge.plus")
            }
        }

        // Details section
        Section {
            Button {
                playable.showDetails(for: content)
            } label: {
                Label("Ver Detalhes", systemImage: "info.circle")
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
                    .font(.footnote)
                    .foregroundStyle(.gray)
            }
            .padding(.vertical, .spacing(.xSmall))
            .background(Color.systemBackground)
        }
    }

    struct ContentWithDescriptionMatch: View {

        let content: AnyEquatableMedoContent
        let highlight: String
        @Bindable var playable: PlayableContentState

        private let contextRadius = 40

        private var text: AttributedString {
            let description = content.description

            // Find the match location in the original string
            guard let matchRange = description.range(of: highlight, options: .caseInsensitive) else {
                return AttributedString(description)
            }

            // Calculate snippet bounds centered around the match
            let matchStartOffset = description.distance(from: description.startIndex, to: matchRange.lowerBound)
            let matchEndOffset = description.distance(from: description.startIndex, to: matchRange.upperBound)

            let snippetStartOffset = max(0, matchStartOffset - contextRadius)
            let snippetEndOffset = min(description.count, matchEndOffset + contextRadius)

            let snippetStart = description.index(description.startIndex, offsetBy: snippetStartOffset)
            let snippetEnd = description.index(description.startIndex, offsetBy: snippetEndOffset)

            var snippet = String(description[snippetStart..<snippetEnd])

            // Add ellipsis if truncated
            if snippetStartOffset > 0 { snippet = "..." + snippet }
            if snippetEndOffset < description.count { snippet = snippet + "..." }

            // Apply highlight to the snippet
            var attributedString = AttributedString(snippet)
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
                    favorites: playable.favoritesKeeper,
                    highlighted: Set<String>(),
                    nowPlaying: playable.nowPlayingKeeper,
                    selectedItems: Set<String>(),
                    currentContentListMode: .constant(.regular)
                )
                .contentShape(
                    .contextMenuPreview,
                    RoundedRectangle(cornerRadius: .spacing(.large), style: .continuous)
                )
                .onTapGesture {
                    if playable.nowPlayingKeeper.contains(content.id) {
                        AudioPlayer.shared?.togglePlay()
                        playable.nowPlayingKeeper.removeAll()
                    } else {
                        playable.play(content)
                    }
                }
                .contextMenu {
                    Section {
                        Button {
                            playable.share(content: content)
                        } label: {
                            Label(Shared.shareSoundButtonText, systemImage: "square.and.arrow.up")
                        }

                        Button {
                            playable.openShareAsVideoModal(for: content)
                        } label: {
                            Label(Shared.shareAsVideoButtonText, systemImage: "film")
                        }
                    }

                    Section {
                        Button {
                            playable.toggleFavorite(content.id)
                        } label: {
                            Label(
                                playable.favoritesKeeper.contains(content.id) ? Shared.removeFromFavorites : Shared.addToFavorites,
                                systemImage: playable.favoritesKeeper.contains(content.id) ? "star.slash" : "star"
                            )
                        }

                        Button {
                            playable.addToFolder(content)
                        } label: {
                            Label(Shared.addToFolderButtonText, systemImage: "folder.badge.plus")
                        }
                    }

                    Section {
                        Button {
                            playable.showDetails(for: content)
                        } label: {
                            Label("Ver Detalhes", systemImage: "info.circle")
                        }
                    }
                }

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
        let searchString: String
        let contentView: (T) -> ItemView

        @State private var isCollapsed: Bool = true

        @Environment(\.colorScheme) var colorScheme

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
                    if #available(iOS 26, *) {
                        HStack {
                            Spacer()
                            Text("Ver Tudo")
                                .bold()
                            Spacer()
                        }
                        .foregroundStyle(
                            colorScheme == .dark ? .primary : Color.darkestGreen
                        )
                        .frame(height: 46)
                        .glassEffect(
                            .regular.tint(
                                .accentColor.opacity(0.3)
                            ).interactive()
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                isCollapsed.toggle()
                            }
                        }
                    } else {
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
            .onChange(of: searchString) {
                isCollapsed = true
            }
        }
    }
}

// MARK: - Previews

#Preview("No Results") {
    GeometryReader { geometry in
        ScrollView {
            SearchResultsView(
                playable: PlayableContentState(
                    contentRepository: FakeContentRepository(),
                    contentFileManager: ContentFileManager(),
                    analyticsService: FakeAnalyticsService(),
                    screen: .searchResultsView,
                    toast: .constant(nil)
                ),
                searchString: "Bolsorrrgnnn",
                results: SearchResults(),
                containerWidth: geometry.size.width,
                toast: .constant(nil),
                menuOptions: []
            )
            .padding(.all, .spacing(.medium))
        }
    }
}

#Preview("Complete") {
    GeometryReader { geometry in
        ScrollView {
            SearchResultsView(
                playable: PlayableContentState(
                    contentRepository: FakeContentRepository(),
                    contentFileManager: ContentFileManager(),
                    analyticsService: FakeAnalyticsService(),
                    screen: .searchResultsView,
                    toast: .constant(nil)
                ),
                searchString: "Bolso",
                results: SearchResults(
                    soundsMatchingTitle: Sound.sampleSounds.map { AnyEquatableMedoContent($0) },
                    soundsMatchingContent: [Sound.sampleBolsoA, Sound.sampleBolsoB].map { AnyEquatableMedoContent($0) },
                    authors: [.bozo, .omarAziz],
                    folders: [.mockA, .mockB],
                    reactionsMatchingTitle: [.viralMock, .choqueMock],
                    reactionsMatchingFeeling: [.viralMock]
                ),
                containerWidth: geometry.size.width,
                toast: .constant(nil),
                menuOptions: []
            )
            .padding(.all, .spacing(.medium))
        }
    }
}
