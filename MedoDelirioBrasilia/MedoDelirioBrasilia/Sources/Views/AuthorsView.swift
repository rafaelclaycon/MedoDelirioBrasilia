import SwiftUI

struct AuthorsView: View {

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    Text("Em Breve")
                }
            }
            .navigationTitle("Favoritos")
        }
    }

}

struct FavoritesView_Previews: PreviewProvider {

    static var previews: some View {
        AuthorsView()
    }

}
