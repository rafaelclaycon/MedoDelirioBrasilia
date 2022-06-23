import SwiftUI

struct FolderDetailView: View {

    @State var folder: UserFolder
    
    var body: some View {
        VStack {
            Text("Content")
        }
        .navigationTitle("\(folder.symbol) \(folder.title)")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing:
            Menu {
                Button(action: {
                    //viewModel.toggleEpisodeListSorting()
                }) {
                    Label("Editar Símbolo e Nome", systemImage: "pencil")
                }
                
                Button(role: .destructive, action: {
                    //viewModel.dummyCall()
                }, label: {
                    HStack {
                        Text("Apagar Pasta") // Windows 10 uses "Excluir"
                        Image(systemName: "trash")
                    }
                })
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        )
    }

}

struct FolderDetailView_Previews: PreviewProvider {

    static var previews: some View {
        FolderDetailView(folder: UserFolder(symbol: "🤑", title: "Grupo da Economia", backgroundColor: "pastelBabyBlue"))
    }

}
