//
//  AuthorsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 26/05/22.
//

import SwiftUI

struct AuthorsView: View {

    @Binding var sortOption: Int
    @Binding var sortAction: AuthorSortOption
    @Binding var searchTextForControl: String
    public let containerWidth: CGFloat

    @State private var viewModel = ViewModel()
    @State private var searchText = ""
    @State private var currentContentListMode: ContentListMode = .regular
    @State private var columns: [GridItem] = []

    // Dynamic Type
    @ScaledMetric private var authorCountTopPadding = 10
    @ScaledMetric private var authorCountPadBottomPadding = 22

    // MARK: - Computed Properties

    private var searchResults: [Author] {
        if searchText.isEmpty {
            return viewModel.authors
        } else {
            return viewModel.authors.filter { $0.name.lowercased().withoutDiacritics().contains(searchText.lowercased()) }
        }
    }

    // MARK: - Environment

    @Environment(\.push) var push
    @Environment(\.sizeCategory) var sizeCategory

    // MARK: - View Body

    var body: some View {
        VStack {
            LazyVGrid(columns: columns, spacing: .spacing(.large)) {
                if searchResults.isEmpty {
                    NoSearchResultsView(searchText: $searchText)
                } else {
                    ForEach(searchResults) { author in
                        AuthorCell(author: author)
                            .padding(.horizontal, .spacing(.xxSmall))
                            .onTapGesture {
                                push(GeneralNavigationDestination.authorDetail(author))
                            }
                    }
                }
            }
            .searchable(text: $searchText)
            .disableAutocorrection(true)
            .padding(.horizontal)
            .padding(.top, .spacing(.xxSmall))
            .onAppear {
                if viewModel.authors.isEmpty {
                    viewModel.reloadList(sortedBy: AuthorSortOption(rawValue: sortOption) ?? .nameAscending)
                }

                //viewModel.donateActivity()

                updateColumns()
            }
            .onChange(of: containerWidth) {
                updateColumns()
            }
            .onChange(of: sortAction) {
                switch sortAction {
                case .nameAscending:
                    viewModel.sortAuthorsInPlaceByNameAscending()
                case .soundCountDescending:
                    viewModel.sortAuthorsInPlaceBySoundCountDescending()
                case .soundCountAscending:
                    viewModel.sortAuthorsInPlaceBySoundCountAscending()
                }
            }
            .onChange(of: searchText) {
                searchTextForControl = searchText
            }

            if searchText.isEmpty {
                Text("\(viewModel.authors.count) AUTORES")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.top, authorCountTopPadding)
                    .padding(.bottom, authorCountPadBottomPadding)
            }
        }
    }

    private func updateColumns() {
        columns = GridHelper.adaptableColumns(
            listWidth: containerWidth,
            sizeCategory: sizeCategory,
            spacing: UIDevice.isiPhone ? .spacing(.small) : .spacing(.large),
            forceSingleColumnOnPhone: true
        )
    }
}

// MARK: - Preview

#Preview {
    AuthorsView(
        sortOption: .constant(AuthorSortOption.nameAscending.rawValue),
        sortAction: .constant(.nameAscending),
        searchTextForControl: .constant(.empty),
        containerWidth: 390
    )
}
