import SwiftUI

struct AuthorDetailView: View {

    @State var author: Author
    
    var body: some View {
        VStack {
            Text(author.name)
        }
    }

}

struct AuthorDetailView_Previews: PreviewProvider {

    static var previews: some View {
        AuthorDetailView(author: Author(id: "A", name: "João"))
    }

}
