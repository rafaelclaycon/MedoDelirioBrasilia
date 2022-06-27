import SwiftUI

struct FolderDetailView: View {

    @StateObject var viewModel = FolderDetailViewViewModel()
    @State var folder: UserFolder
    @State private var showingFolderInfoEditingView = false
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(viewModel.sounds) { sound in
                        SoundCell(soundId: sound.id, title: sound.title, author: sound.authorName ?? "", favorites: .constant(Set<String>()))
                            .onTapGesture {
                                viewModel.playSound(fromPath: sound.filename)
                            }
                            .onLongPressGesture {
                                viewModel.soundForConfirmationDialog = sound
                                viewModel.showConfirmationDialog = true
                            }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 7)
            }
        }
        .navigationTitle("\(folder.symbol)  \(folder.name)")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing:
            Menu {
                Button(action: {
                    showingFolderInfoEditingView = true
                }) {
                    Label("Editar Pasta", systemImage: "pencil")
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
        .onAppear {
            viewModel.reloadSoundList(withSoundIds: try? database.getAllSoundIdsInsideUserFolder(withId: folder.id))
        }
        .sheet(isPresented: $showingFolderInfoEditingView) {
            FolderInfoEditingView(isBeingShown: $showingFolderInfoEditingView, symbol: folder.symbol, folderName: folder.name, selectedBackgroundColor: folder.backgroundColor, isEditing: true, folderIdWhenEditing: folder.id)
        }
        .confirmationDialog("", isPresented: $viewModel.showConfirmationDialog) {
            Button("📁  Remover da Pasta") {
                guard viewModel.soundForConfirmationDialog != nil else {
                    return
                }
                //showingAddToFolderModal = true
            }
            
            Button(Shared.shareButtonText) {
                guard let sound = viewModel.soundForConfirmationDialog else {
                    return
                }
                viewModel.shareSound(withPath: sound.filename, andContentId: sound.id)
            }
        }
    }

}

struct FolderDetailView_Previews: PreviewProvider {

    static var previews: some View {
        FolderDetailView(folder: UserFolder(symbol: "🤑", name: "Grupo da Economia", backgroundColor: "pastelBabyBlue"))
    }

}
