import SwiftUI

struct CollectionsView: View {

    @StateObject private var viewModel = CollectionsViewViewModel()
    @State private var showingFolderInfoEditingView = false
    @State private var folderForEditingOnSheet: UserFolder? = nil
    
    private let rows = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
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
        ScrollView {
            VStack(alignment: .center) {
                VStack(alignment: .center) {
                    HStack {
                        Text("Escolhas dos Editores")
                            .font(.title2)
                            .padding(.leading)
                        
                        Spacer()
                    }
                    
                    VStack(spacing: 10) {
                        Text("Em Breve")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 100)
                    
//                        ScrollView(.horizontal, showsIndicators: false) {
//                            LazyHGrid(rows: rows, spacing: 14) {
//                                ForEach(viewModel.collections) { collection in
//                                    NavigationLink {
//                                        CollectionDetailView()
//                                    } label: {
//                                        CollectionCell(title: collection.title, imageURL: collection.imageURL)
//                                    }
//                                }
//                            }
//                            .frame(height: 210)
//                            .padding(.leading)
//                            .padding(.trailing)
//                        }
                }
                .padding(.top, 10)
                
                //if UIDevice.current.userInterfaceIdiom == .phone {
                    VStack(alignment: .center) {
                        HStack {
                            Text("Minhas Pastas")
                                .font(.title2)
                            
                            Spacer()
                            
                            Button {
                                showingFolderInfoEditingView = true
                            } label: {
                                HStack {
                                    Image(systemName: "plus")
                                    Text("Nova Pasta")
                                }
                            }
                            .onChange(of: showingFolderInfoEditingView) { newValue in
                                if newValue == false {
                                    viewModel.reloadFolderList(withFolders: try? database.getAllUserFolders())
                                    folderForEditingOnSheet = nil
                                }
                            }
                        }
                        
                        if viewModel.hasFoldersToDisplay {
                            LazyVGrid(columns: columns, spacing: 14) {
                                ForEach(viewModel.folders) { folder in
                                    NavigationLink {
                                        FolderDetailView(folder: folder)
                                    } label: {
                                        FolderCell(symbol: folder.symbol, name: folder.name, backgroundColor: folder.backgroundColor.toColor())
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
                                            viewModel.showFolderDeletionConfirmation(folderName: "\(folder.symbol) \(folder.name)", folderId: folder.id)
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
                            }
                            .padding(.vertical, 40)
                        }
                    }
                    .padding(.top, 10)
                    .padding(.horizontal)
                //}
            }
            .navigationTitle("Coleções")
            .sheet(isPresented: $showingFolderInfoEditingView) {
                if let folder = folderForEditingOnSheet {
                    FolderInfoEditingView(isBeingShown: $showingFolderInfoEditingView, symbol: folder.symbol, folderName: folder.name, selectedBackgroundColor: folder.backgroundColor, isEditing: true, folderIdWhenEditing: folder.id)
                } else {
                    FolderInfoEditingView(isBeingShown: $showingFolderInfoEditingView, selectedBackgroundColor: "pastelPurple")
                }
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage), primaryButton: .destructive(Text("Apagar"), action: {
                    guard viewModel.folderIdForDeletion.isEmpty == false else {
                        return
                    }
                    try? database.deleteUserFolder(withId: viewModel.folderIdForDeletion)
                    viewModel.reloadFolderList(withFolders: try? database.getAllUserFolders())
                }), secondaryButton: .cancel(Text("Cancelar")))
            }
            .onAppear {
                //viewModel.reloadCollectionList(withCollections: getLocalCollections())
                viewModel.reloadFolderList(withFolders: try? database.getAllUserFolders())
                viewModel.donateActivity()
            }
            .padding(.bottom)
        }
    }
    
    private func getLocalCollections() -> [ContentCollection] {
        var array = [ContentCollection]()
        array.append(ContentCollection(title: "LGBT", imageURL: "http://blog.saude.mg.gov.br/wp-content/uploads/2021/06/28-06-lgbt.jpg"))
        array.append(ContentCollection(title: "Clássicos", imageURL: "https://www.avina.net/wp-content/uploads/2019/06/Confiamos-no-Brasil-e-nos-brasileiros-e-brasileiras.jpg"))
        array.append(ContentCollection(title: "Sérios", imageURL: "https://images.trustinnews.pt/uploads/sites/5/2019/10/tres-tabus-que-o-homem-atual-ja-ultrapassou-2.jpeg"))
        array.append(ContentCollection(title: "Invasão Foro", imageURL: "https://i.scdn.co/image/0a32a3b9a4f798833f1c10aac18197f7b119e758"))
        array.append(ContentCollection(title: "Memes", imageURL: "https://i.ytimg.com/vi/r0jh29F6hSs/mqdefault.jpg"))
        return array
    }

}

struct CollectionsView_Previews: PreviewProvider {

    static var previews: some View {
        CollectionsView()
    }

}
