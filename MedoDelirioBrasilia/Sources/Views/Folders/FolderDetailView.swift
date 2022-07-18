import SwiftUI

struct FolderDetailView: View {

    @StateObject var viewModel = FolderDetailViewViewModel()
    @State var folder: UserFolder
    @State private var showingFolderInfoEditingView = false
    
    private var columns: [GridItem] {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return [
                GridItem(.flexible()),
                GridItem(.flexible())
            ]
        } else {
            return [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ]
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                if viewModel.hasSoundsToDisplay {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: UIDevice.current.userInterfaceIdiom == .phone ? 14 : 20) {
                            ForEach(viewModel.sounds) { sound in
                                SoundCell(soundId: sound.id, title: sound.title, author: sound.authorName ?? "", favorites: .constant(Set<String>()))
                                    .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 0 : 5)
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
                } else {
                    EmptyFolderView()
                        .padding(.horizontal, 30)
                }
            }
            .navigationTitle("\(folder.symbol)  \(folder.name)")
            .navigationBarTitleDisplayMode(.inline)
    //        .navigationBarItems(trailing:
    //            Menu {
    //                Button(action: {
    //                    showingFolderInfoEditingView = true
    //                }) {
    //                    Label("Editar Pasta", systemImage: "pencil")
    //                }
    //
    //                Button(role: .destructive, action: {
    //                    //viewModel.dummyCall()
    //                }, label: {
    //                    HStack {
    //                        Text("Apagar Pasta")
    //                        Image(systemName: "trash")
    //                    }
    //                })
    //            } label: {
    //                Image(systemName: "ellipsis.circle")
    //            }
    //        )
            .onAppear {
                viewModel.reloadSoundList(withSoundIds: try? database.getAllSoundIdsInsideUserFolder(withId: folder.id))
            }
            .sheet(isPresented: $showingFolderInfoEditingView) {
                FolderInfoEditingView(isBeingShown: $showingFolderInfoEditingView, symbol: folder.symbol, folderName: folder.name, selectedBackgroundColor: folder.backgroundColor, isEditing: true, folderIdWhenEditing: folder.id)
            }
            .confirmationDialog("", isPresented: $viewModel.showConfirmationDialog) {
                Button("📁  Remover da Pasta") {
                    guard let sound = viewModel.soundForConfirmationDialog else {
                        return
                    }
                    viewModel.showSoundRemovalConfirmation(soundTitle: sound.title)
                }
                
                Button(Shared.shareButtonText) {
                    guard let sound = viewModel.soundForConfirmationDialog else {
                        return
                    }
                    viewModel.shareSound(withPath: sound.filename, andContentId: sound.id)
                }
            }
            .alert(isPresented: $viewModel.showAlert) {
                switch viewModel.alertType {
                case .singleOption:
                    return Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
                default:
                    return Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage), primaryButton: .destructive(Text("Remover"), action: {
                        guard let sound = viewModel.soundForConfirmationDialog else {
                            return
                        }
                        viewModel.removeSoundFromFolder(folderId: folder.id, soundId: sound.id)
                    }), secondaryButton: .cancel(Text("Cancelar")))
                }
            }
            .onChange(of: viewModel.showConfirmationDialog) { show in
                if show {
                    TapticFeedback.open()
                }
            }
            
            if viewModel.shouldDisplaySharedSuccessfullyToast {
                VStack {
                    Spacer()
                    
                    ToastView(text: Shared.soundSharedSuccessfullyMessage)
                        .padding()
                }
                .transition(.moveAndFade)
            }
        }
    }

}

struct FolderDetailView_Previews: PreviewProvider {

    static var previews: some View {
        FolderDetailView(folder: UserFolder(symbol: "🤑", name: "Grupo da Economia", backgroundColor: "pastelBabyBlue"))
    }

}
