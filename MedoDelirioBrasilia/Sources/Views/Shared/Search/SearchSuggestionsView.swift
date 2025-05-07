//
//  SearchSuggestionsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 03/05/25.
//

import SwiftUI

struct SearchSuggestionsView: View {

    @State var recent: [String]
    let trendsService: TrendsServiceProtocol
    let onRecentSelectedAction: (String) -> Void
    let onReactionSelectedAction: (Reaction) -> Void
    let containerWidth: CGFloat
    let onClearSearchesAction: () -> Void

    @State private var popularContent: LoadingState<[AnyEquatableMedoContent]> = .loading
    @State private var popularReactions: LoadingState<[Reaction]> = .loading

    @State private var columns: [GridItem] = []

    private let phoneItemSpacing: CGFloat = .spacing(.small)
    private let padItemSpacing: CGFloat = .spacing(.medium)

    @Environment(\.sizeCategory) private var sizeCategory

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

            if case .loaded(let content) = popularContent, !content.isEmpty {
                PopularContentView(
                    content: content,
                    columns: columns,
                    phoneItemSpacing: phoneItemSpacing,
                    padItemSpacing: padItemSpacing
                )
            }

            if case .loaded(let reactions) = popularReactions, !reactions.isEmpty {
                PopularReactionsView(
                    reactions: reactions,
                    onReactionSelectedAction: onReactionSelectedAction,
                    columns: columns,
                    phoneItemSpacing: phoneItemSpacing,
                    padItemSpacing: padItemSpacing
                )
            }
        }
        .onAppear {
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
            popularContent = .loaded(try await trendsService.top3Content())
            popularReactions = .loaded(try await trendsService.top3Reactions())
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

    struct PopularContentView: View {

        let content: [AnyEquatableMedoContent]
        let columns: [GridItem]
        let phoneItemSpacing: CGFloat
        let padItemSpacing: CGFloat

        var body: some View {
            VStack(alignment: .leading, spacing: .spacing(.medium)) {
                Text("Conteúdos Populares")
                    .font(.headline)

                LazyVGrid(columns: columns, spacing: UIDevice.isiPhone ? phoneItemSpacing : padItemSpacing) {
                    ForEach(content) { item in
                        PlayableContentView(
                            content: item,
                            favorites: Set<String>(),
                            highlighted: Set<String>(),
                            nowPlaying: Set<String>(),
                            selectedItems: Set<String>(),
                            currentContentListMode: .constant(.regular)
                        )
                    }
                }
            }
        }
    }

    struct PopularReactionsView: View {

        let reactions: [Reaction]
        let onReactionSelectedAction: (Reaction) -> Void
        let columns: [GridItem]
        let phoneItemSpacing: CGFloat
        let padItemSpacing: CGFloat

        var body: some View {
            VStack(alignment: .leading, spacing: .spacing(.medium)) {
                Text("Reações Populares")
                    .font(.headline)

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
}

// MARK: - Preview

#Preview {
    GeometryReader { geometry in
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    SearchSuggestionsView(
                        recent: [],
                        trendsService: TrendsService(
                            database: FakeLocalDatabase(),
                            apiClient: FakeAPIClient(),
                            contentRepository: FakeContentRepository()
                        ),
                        onRecentSelectedAction: { _ in },
                        onReactionSelectedAction: { _ in },
                        containerWidth: geometry.size.width,
                        onClearSearchesAction: {}
                    )

                    Spacer()
                }
            }
            .padding(.spacing(.medium))
        }
    }
}
