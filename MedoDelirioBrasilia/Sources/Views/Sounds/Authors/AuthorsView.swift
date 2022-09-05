import SwiftUI

struct AuthorsView: View {

    @StateObject private var viewModel = AuthorsViewViewModel()
    @State private var searchText = ""
    
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
                ForEach(searchResults) { author in
                    NavigationLink(destination: AuthorDetailView(author: author)) {
                        AuthorCell(authorName: author.name, authorImageURL: author.photo ?? "", soundCount: "\(author.soundCount ?? 0)")
                            .padding(.horizontal, 5)
                    }
                }
            }
            .searchable(text: $searchText)
            .disableAutocorrection(true)
            .padding(.horizontal)
            .padding(.top, 7)
            .padding(.bottom, 18)
            .onAppear {
                viewModel.reloadList()
                //viewModel.donateActivity()
            }
        }
    }

}

struct FavoritesView_Previews: PreviewProvider {

    static var previews: some View {
        AuthorsView()
    }

}
