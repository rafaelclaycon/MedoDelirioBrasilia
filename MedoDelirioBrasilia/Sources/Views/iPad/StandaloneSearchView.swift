//
//  StandaloneSearchView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 03/05/25.
//

import SwiftUI

struct StandaloneSearchView: View {

    let searchService: SearchServiceProtocol
    let trendsService: TrendsServiceProtocol
    let contentRepository: ContentRepositoryProtocol
    let userFolderRepository: UserFolderRepositoryProtocol
    let analyticsService: AnalyticsServiceProtocol

    @State private var searchText: String = ""
    @State private var searchResults = SearchResults()
    @State private var toast: Toast? = nil
    @State private var playable: PlayableContentState?

    @Environment(\.push) private var push

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: .spacing(.xSmall)) {
                    if let playable {
                        if searchText.isEmpty {
                            SearchSuggestionsView(
                                recent: searchService.recentSearches(),
                                playable: playable,
                                trendsService: trendsService,
                                onRecentSelectedAction: {
                                    searchText = $0
                                },
                                onReactionSelectedAction: { push(GeneralNavigationDestination.reactionDetail($0)) },
                                containerWidth: geometry.size.width,
                                toast: $toast,
                                onClearSearchesAction: searchService.clearRecentSearches
                            )
                            .padding(.horizontal, .spacing(.medium))
                        } else {
                            SearchResultsView(
                                playable: playable,
                                searchString: searchText,
                                results: searchResults,
                                containerWidth: geometry.size.width,
                                toast: $toast,
                                menuOptions: [.sharingOptions(), .organizingOptions(), .detailsOptions()]
                            )
                            .padding(.horizontal, UIDevice.isiPhone ? .spacing(.xSmall) : 0)
                        }
                    }
                }
                .padding(.all, UIDevice.isiPad ? .spacing(.medium) : .spacing(.xSmall))
                .navigationTitle(Text("Buscar"))
                .searchable(text: $searchText, placement: .navigationBarDrawer, prompt: Shared.Search.searchPrompt)
                .autocorrectionDisabled()
                .onChange(of: searchText) {
                    onSearchStringChanged(newString: searchText)
                }
            }
            .toast($toast)
            .onAppear {
                if playable == nil {
                    playable = PlayableContentState(
                        contentRepository: contentRepository,
                        contentFileManager: ContentFileManager(),
                        analyticsService: analyticsService,
                        screen: .searchResultsView,
                        toast: $toast
                    )
                }
            }
        }
    }

    private func onSearchStringChanged(newString: String) {
        guard !newString.isEmpty else {
            searchResults.clearAll()
            return
        }
        searchResults = searchService.results(matching: newString)
    }
}

// MARK: - Preview

#Preview {
    StandaloneSearchView(
        searchService: SearchService(
            contentRepository: FakeContentRepository(),
            authorService: FakeAuthorService(),
            appMemory: FakeAppPersistentMemory(),
            userFolderRepository: FakeUserFolderRepository(),
            userSettings: FakeUserSettings()
        ),
        trendsService: TrendsService(
            database: FakeLocalDatabase(),
            apiClient: FakeAPIClient(),
            contentRepository: FakeContentRepository()
        ),
        contentRepository: FakeContentRepository(),
        userFolderRepository: FakeUserFolderRepository(),
        analyticsService: FakeAnalyticsService()
    )
}
