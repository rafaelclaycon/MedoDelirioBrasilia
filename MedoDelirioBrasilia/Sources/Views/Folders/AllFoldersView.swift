import SwiftUI

struct AllFoldersView: View {

    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                Text("Teste")
            }
        }
        .navigationTitle("Pastas")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    //showingFolderInfoEditingView = true
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Nova Pasta")
                    }
                }
            }
        }
    }

}

struct AllFoldersView_Previews: PreviewProvider {

    static var previews: some View {
        AllFoldersView()
    }

}
