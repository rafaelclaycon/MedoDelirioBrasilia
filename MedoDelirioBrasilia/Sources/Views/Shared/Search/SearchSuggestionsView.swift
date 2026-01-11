//
//  SearchSuggestionsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 03/05/25.
//

import SwiftUI

struct SearchSuggestionsView: View {

    @State var recent: [String]
    @State var playable: PlayableContentState
    let trendsService: TrendsServiceProtocol
    let onRecentSelectedAction: (String) -> Void
    let onReactionSelectedAction: (Reaction) -> Void
    let containerWidth: CGFloat
    var toast: Binding<Toast?>
    let onClearSearchesAction: () -> Void

    @State private var popularContent: LoadingState<[AnyEquatableMedoContent]> = .loading
    @State private var popularReactions: LoadingState<[Reaction]> = .loading

    @State private var columns: [GridItem] = []

    private let phoneItemSpacing: CGFloat = .spacing(.small)
    private let padItemSpacing: CGFloat = .spacing(.medium)

    @Environment(\.sizeCategory) private var sizeCategory
    @Environment(\.push) private var push

    // MARK: - View Body

    var body: some View {
        VStack(alignment: .leading, spacing: .spacing(.xLarge)) {
            if !recent.isEmpty {
                VStack(alignment: .leading, spacing: .spacing(.medium)) {
                    HStack {
                        Text("Pesquisas Recentes")
                            .font(.headline)

                        Spacer()

                        Button {
                            recent.removeAll()
                            onClearSearchesAction()
                        } label: {
                            Text("Limpar")
                        }
                        .miniButton(colored: .green)
                    }

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

            VStack(alignment: .leading, spacing: .spacing(.medium)) {
                Text("🔥 Em Alta Hoje")
                    .font(.headline)

                switch popularContent {
                case .loading:
                    HStack {
                        ProgressView()
                        Spacer()
                    }
                    .frame(height: 80)

                case .loaded(let content) where !content.isEmpty:
                    PopularContentGrid(
                        content: content,
                        playable: playable,
                        columns: columns,
                        phoneItemSpacing: phoneItemSpacing,
                        padItemSpacing: padItemSpacing
                    )
                    .transition(.slideFromLeading)

                default:
                    EmptyView()
                }
            }

            VStack(alignment: .leading, spacing: .spacing(.medium)) {
                Text("Reações Populares")
                    .font(.headline)

                switch popularReactions {
                case .loading:
                    HStack {
                        ProgressView()
                        Spacer()
                    }
                    .frame(height: 80)

                case .loaded(let reactions) where !reactions.isEmpty:
                    PopularReactionsGrid(
                        reactions: reactions,
                        onReactionSelectedAction: onReactionSelectedAction,
                        columns: columns,
                        phoneItemSpacing: phoneItemSpacing,
                        padItemSpacing: padItemSpacing
                    )
                    .transition(.slideFromLeading)

                default:
                    EmptyView()
                }
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
            Task {
                await loadContent()
            }
            updateGridLayout()
        }
        .onChange(of: containerWidth) {
            updateGridLayout()
        }
    }

    // MARK: - Functions

    private func loadContent() async {
        popularContent = .loading
        popularReactions = .loading
        do {
            let content = try await trendsService.top3Content()
            withAnimation(.easeOut(duration: 0.3)) {
                popularContent = .loaded(content)
            }

            let reactions = try await trendsService.top3Reactions()
            withAnimation(.easeOut(duration: 0.3).delay(0.1)) {
                popularReactions = .loaded(reactions)
            }
        } catch {
            popularContent = .error("")
            popularReactions = .error("")
            debugPrint(error)
        }
    }

    private func updateGridLayout() {
        columns = GridHelper.adaptableColumns(
            listWidth: containerWidth,
            sizeCategory: sizeCategory,
            spacing: UIDevice.isiPhone ? phoneItemSpacing : padItemSpacing
        )
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

    struct PopularContentGrid: View {

        let content: [AnyEquatableMedoContent]
        @Bindable var playable: PlayableContentState
        let columns: [GridItem]
        let phoneItemSpacing: CGFloat
        let padItemSpacing: CGFloat

        var body: some View {
            LazyVGrid(columns: columns, spacing: UIDevice.isiPhone ? phoneItemSpacing : padItemSpacing) {
                ForEach(content) { item in
                    PlayableContentView(
                        content: item,
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
                        if playable.nowPlayingKeeper.contains(item.id) {
                            AudioPlayer.shared?.togglePlay()
                            playable.nowPlayingKeeper.removeAll()
                        } else {
                            playable.play(item)
                        }
                    }
                    .contextMenu {
                        // Sharing
                        Section {
                            Button {
                                playable.share(content: item)
                            } label: {
                                Label(Shared.shareSoundButtonText, systemImage: "square.and.arrow.up")
                            }

                            Button {
                                playable.openShareAsVideoModal(for: item)
                            } label: {
                                Label(Shared.shareAsVideoButtonText, systemImage: "film")
                            }
                        }

                        // Organizing
                        Section {
                            Button {
                                playable.toggleFavorite(item.id)
                            } label: {
                                Label(
                                    playable.favoritesKeeper.contains(item.id) ? Shared.removeFromFavorites : Shared.addToFavorites,
                                    systemImage: playable.favoritesKeeper.contains(item.id) ? "star.slash" : "star"
                                )
                            }

                            Button {
                                playable.addToFolder(item)
                            } label: {
                                Label(Shared.addToFolderButtonText, systemImage: "folder.badge.plus")
                            }
                        }

                        // Details
                        Section {
                            Button {
                                playable.showDetails(for: item)
                            } label: {
                                Label("Ver Detalhes", systemImage: "info.circle")
                            }
                        }
                    }
                }
            }
        }
    }

    struct PopularReactionsGrid: View {

        let reactions: [Reaction]
        let onReactionSelectedAction: (Reaction) -> Void
        let columns: [GridItem]
        let phoneItemSpacing: CGFloat
        let padItemSpacing: CGFloat

        var body: some View {
            LazyVGrid(columns: columns, spacing: UIDevice.isiPhone ? phoneItemSpacing : padItemSpacing) {
                ForEach(reactions) { reaction in
                    ReactionItem(reaction: reaction)
                        .onTapGesture {
                            onReactionSelectedAction(reaction)
                        }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    GeometryReader { geometry in
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    SearchSuggestionsView(
                        recent: [],
                        playable: PlayableContentState(
                            contentRepository: FakeContentRepository(),
                            contentFileManager: ContentFileManager(),
                            analyticsService: FakeAnalyticsService(),
                            screen: .searchResultsView,
                            toast: .constant(nil)
                        ),
                        trendsService: TrendsService(
                            database: FakeLocalDatabase(),
                            apiClient: FakeAPIClient(),
                            contentRepository: FakeContentRepository()
                        ),
                        onRecentSelectedAction: { _ in },
                        onReactionSelectedAction: { _ in },
                        containerWidth: geometry.size.width,
                        toast: .constant(nil),
                        onClearSearchesAction: {}
                    )

                    Spacer()
                }
            }
            .padding(.spacing(.medium))
        }
    }
}
