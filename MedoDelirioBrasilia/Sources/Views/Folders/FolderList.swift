import SwiftUI

/// Sub-view loaded inside the Collections tab on iPhone and the All Folders tab on iPad and Mac.
struct FolderList: View {

    @StateObject private var viewModel = FolderListViewModel()
    @Binding var updateFolderList: Bool
    @Binding var deleteFolderAid: DeleteFolderViewAid
    
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
        VStack {
            if viewModel.hasFoldersToDisplay {
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(viewModel.folders) { folder in
                        NavigationLink {
                            FolderDetailView(folder: folder)
                        } label: {
                            FolderCell(symbol: folder.symbol, name: folder.name, backgroundColor: folder.backgroundColor.toColor())
                                .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 0 : 5)
                        }
                        .foregroundColor(.primary)
                        .contextMenu {
    //                                        Button {
    //                                            folderForEditingOnSheet = folder
    //                                            showingFolderInfoEditingView = true
    //                                        } label: {
    //                                            Label("Editar Pasta", systemImage: "pencil")
    //                                        }
                            
                            Button(role: .destructive, action: {
                                let folderName = "\(folder.symbol) \(folder.name)"
                                deleteFolderAid.alertTitle = "Apagar a Pasta \"\(folderName)\"?"
                                deleteFolderAid.alertMessage = "Os sons continuarão disponíveis no app, fora da pasta.\n\nEssa ação não pode ser desfeita."
                                deleteFolderAid.folderIdForDeletion = folder.id
                                deleteFolderAid.showAlert = true
                            }, label: {
                                HStack {
                                    Text("Apagar Pasta")
                                    Image(systemName: "trash")
                                }
                            })
                        }
                    }
                }
            } else {
                VStack(spacing: 15) {
                    Spacer()
                    
                    Image(systemName: "folder")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90)
                        .foregroundColor(.blue)
                        .padding(.bottom, 10)
                    
                    Text("Nenhuma Pasta Criada")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                    
                    Text("Toque em Nova Pasta acima para criar uma nova pasta de sons.")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.vertical, 40)
            }
        }
        .onAppear {
            viewModel.reloadFolderList(withFolders: try? database.getAllUserFolders())
            viewModel.donateActivity()
        }
        .onChange(of: updateFolderList) { shouldUpdate in
            if shouldUpdate {
                viewModel.reloadFolderList(withFolders: try? database.getAllUserFolders())
                updateFolderList = false
            }
        }
    }

}

struct FolderList_Previews: PreviewProvider {

    static var previews: some View {
        FolderList(updateFolderList: .constant(false), deleteFolderAid: .constant(DeleteFolderViewAid()))
    }

}
