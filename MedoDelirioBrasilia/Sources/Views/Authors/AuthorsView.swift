//
//  AuthorsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 26/05/22.
//

import SwiftUI

struct AuthorsView: View {

    @StateObject private var viewModel = ViewModel()
    @State private var searchText = ""
    @Binding var sortOption: Int
    @Binding var sortAction: AuthorSortOption
    @Binding var searchTextForControl: String
    @State var currentSoundsListMode: SoundsListMode = .regular

    // Dynamic Type
    @ScaledMetric private var authorCountTopPadding = 10
    @ScaledMetric private var authorCountPhoneBottomPadding = 68
    @ScaledMetric private var authorCountPadBottomPadding = 22

    var searchResults: [Author] {
        if searchText.isEmpty {
            return viewModel.authors
        } else {
            return viewModel.authors.filter { $0.name.lowercased().withoutDiacritics().contains(searchText.lowercased()) }
        }
    }

    @State private var columns: [GridItem] = []

    @Environment(\.push) var push
    @Environment(\.sizeCategory) var sizeCategory

    var body: some View {
        VStack {
            LazyVGrid(columns: columns, spacing: 20) {
                if searchResults.isEmpty {
                    NoSearchResultsView(searchText: $searchText)
                } else {
                    ForEach(searchResults) { author in
                        AuthorCell(author: author)
                            .padding(.horizontal, 5)
                            .onTapGesture {
                                push(GeneralNavigationDestination.authorDetail(author))
                            }
                    }
                }
            }
            .searchable(text: $searchText)
            .disableAutocorrection(true)
            .padding(.horizontal)
            .padding(.top, 7)
            .onAppear {
                if viewModel.authors.isEmpty {
                    viewModel.reloadList(sortedBy: AuthorSortOption(rawValue: sortOption) ?? .nameAscending)
                }

                //viewModel.donateActivity()

                columns = GridHelper.adaptableColumns(
                    listWidth: UIScreen.main.bounds.width,
                    sizeCategory: sizeCategory,
                    spacing: UIDevice.isiPhone ? 12 : 20,
                    forceSingleColumnOnPhone: true
                )
            }
            //                .onChange(of: geometry.size.width) { newWidth in
            //                    columns = GridHelper.adaptableColumns(
            //                        listWidth: newWidth,
            //                        sizeCategory: sizeCategory,
            //                        spacing: UIDevice.isiPhone ? 12 : 20,
            //                        forceSingleColumnOnPhone: true
            //                    )
            //                }
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
                    .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? authorCountPhoneBottomPadding : authorCountPadBottomPadding)
            }
        }
    }
}

#Preview {
    AuthorsView(
        sortOption: .constant(AuthorSortOption.nameAscending.rawValue),
        sortAction: .constant(.nameAscending),
        searchTextForControl: .constant(.empty)
    )
}
