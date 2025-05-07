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

    @State private var searchText: String = ""
    @State private var searchResults = SearchResults()

    @Environment(\.push) private var push

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: .spacing(.xSmall)) {
                    if searchText.isEmpty {
                        SearchSuggestionsView(
                            recent: searchService.recentSearches(),
                            trendsService: trendsService,
                            onRecentSelectedAction: {
                                searchText = $0
                            },
                            onReactionSelectedAction: { push(GeneralNavigationDestination.reactionDetail($0)) },
                            containerWidth: geometry.size.width
                        )
                        .padding(.leading, .spacing(.medium))
                    } else {
                        SearchResultsView(
                            searchString: searchText,
                            results: searchResults,
                            containerWidth: geometry.size.width
                        )
                    }
                }
                .padding([.leading, .vertical], .spacing(.medium))
                .navigationTitle(Text("Buscar"))
                .searchable(text: $searchText, placement: .navigationBarDrawer, prompt: Shared.Search.searchPrompt)
                .autocorrectionDisabled()
                .onChange(of: searchText) {
                    onSearchStringChanged(newString: searchText)
                }
//                .onAppear {
//                    viewModel.onViewDidAppear()
//                    contentGridViewModel.onViewAppeared()
//                }
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
            appMemory: FakeAppPersistentMemory()
        ),
        trendsService: TrendsService(
            database: FakeLocalDatabase(),
            apiClient: FakeAPIClient(),
            contentRepository: FakeContentRepository()
        )
    )
}
