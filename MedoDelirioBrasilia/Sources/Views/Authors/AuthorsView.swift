//
//  AuthorsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 26/05/22.
//

import SwiftUI

struct AuthorsView: View {

    @StateObject private var viewModel = AuthorsViewViewModel()
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
    
    private var columns: [GridItem] {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return [
                GridItem(.flexible())
            ]
        } else {
            return [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ]
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                if searchResults.isEmpty {
                    NoSearchResultsView(searchText: $searchText)
                        //.padding(.vertical, UIScreen.main.bounds.height / 4)
                } else {
                    ForEach(searchResults) { author in
                        NavigationLink(destination: AuthorDetailView(viewModel: AuthorDetailViewViewModel(originatingScreenName: searchText.isEmpty ? Shared.ScreenNames.authorsView : "\(Shared.ScreenNames.authorsView)(\(searchText))", authorName: author.name, currentSoundsListMode: $currentSoundsListMode), author: author, currentSoundsListMode: $currentSoundsListMode)) {
                            AuthorCell(authorName: author.name, authorImageURL: author.photo ?? "", soundCount: "\(author.soundCount ?? 0)")
                                .padding(.horizontal, 5)
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
            }
            .onChange(of: sortAction) { sortAction in
                switch sortAction {
                case .nameAscending:
                    viewModel.sortAuthorsInPlaceByNameAscending()
                case .soundCountDescending:
                    viewModel.sortAuthorsInPlaceBySoundCountDescending()
                case .soundCountAscending:
                    viewModel.sortAuthorsInPlaceBySoundCountAscending()
                }
            }
            .onChange(of: searchText) { searchText in
                searchTextForControl = searchText
            }

            if searchText.isEmpty {
                Text("\(viewModel.authors.count) AUTORES.")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.top, authorCountTopPadding)
                    .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? authorCountPhoneBottomPadding : authorCountPadBottomPadding)
            }
        }
    }

}

struct FavoritesView_Previews: PreviewProvider {

    static var previews: some View {
        AuthorsView(sortOption: .constant(AuthorSortOption.nameAscending.rawValue), sortAction: .constant(.nameAscending), searchTextForControl: .constant(.empty))
    }

}
