import SwiftUI

struct AuthorsView: View {

    @StateObject private var viewModel = AuthorsViewViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.authors) { author in
                NavigationLink(destination: AuthorDetailView(author: author)) {
                    Text(author.name)
                }
            }
            .navigationTitle("Autores")
            .onAppear {
                viewModel.reloadList()
            }
        }
    }

}

struct FavoritesView_Previews: PreviewProvider {

    static var previews: some View {
        AuthorsView()
    }

}
