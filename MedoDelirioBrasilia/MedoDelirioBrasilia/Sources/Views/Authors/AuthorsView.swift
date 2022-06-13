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
    
    var body: some View {
        NavigationView {
            List(searchResults) { author in
                NavigationLink(destination: AuthorDetailView(author: author)) {
                    Text(author.name)
                }
            }
            .searchable(text: $searchText)
            .disableAutocorrection(true)
            .navigationTitle("Autores")
            .onAppear {
                viewModel.reloadList()
                viewModel.donateActivity()
            }
        }
    }

}

struct FavoritesView_Previews: PreviewProvider {

    static var previews: some View {
        AuthorsView()
    }

}
