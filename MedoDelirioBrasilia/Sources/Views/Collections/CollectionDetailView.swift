import SwiftUI

struct CollectionDetailView: View {

    @StateObject var viewModel = FolderDetailViewViewModel()
    @State var collection: ContentCollection
    
    var body: some View {
        Text("Hello, World!")
    }

}

struct CollectionDetailView_Previews: PreviewProvider {

    static var previews: some View {
        CollectionDetailView(collection: ContentCollection(title: "Teste", imageURL: .empty))
    }

}
