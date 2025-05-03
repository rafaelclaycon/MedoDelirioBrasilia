//
//  StandaloneSearchView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 03/05/25.
//

import SwiftUI

struct StandaloneSearchView: View {

    let searchService: SearchServiceProtocol

    @State private var searchText: String = ""
    @State private var searchResults = SearchResults()

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: .spacing(.xSmall)) {
                    SearchResultsView(
                        searchString: searchText,
                        results: searchResults,
                        containerWidth: geometry.size.width
                    )
                }
                .padding(.all, .spacing(.medium))
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
        print("RAFA - new search string: \(newString)")
        guard !newString.isEmpty else {
            searchResults.clearAll()
            return
        }
        searchResults = searchService.results(matching: newString)
        print(searchResults.soundsMatchingTitle?.count)
    }
}

// MARK: - Preview

#Preview {
    StandaloneSearchView(searchService:
        SearchService(
            database: FakeLocalDatabase(),
            contentRepository: FakeContentRepository(),
            authorService: FakeAuthorService()
        )
    )
}
