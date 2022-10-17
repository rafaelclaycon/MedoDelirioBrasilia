import SwiftUI

struct CollectionsView: View {

    @StateObject private var viewModel = CollectionsViewViewModel()
    @Binding var isShowingFolderInfoEditingSheet: Bool
    @State private var folderForEditingOnSheet: UserFolder? = nil
    @State var updateFolderList: Bool = false
    @State var deleteFolderAid = DeleteFolderViewAid()
    
    private let rows = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                VStack(alignment: .center) {
                    HStack {
                        Text("Escolhas do Editor")
                            .font(.title2)
                            .padding(.leading)
                        
                        Spacer()
                    }
                    
//                    VStack(spacing: 10) {
//                        Text("Nenhuma Coleção")
//                            .foregroundColor(.gray)
//                            .font(.title3)
//                            .multilineTextAlignment(.center)
//                    }
//                    .padding(.vertical, UIDevice.current.userInterfaceIdiom == .phone ? 100 : 200)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: rows, spacing: 14) {
                            ForEach(viewModel.collections) { collection in
                                NavigationLink {
                                    CollectionDetailView(collection: collection)
                                } label: {
                                    CollectionCell(title: collection.title, imageURL: collection.imageURL)
                                }
                            }
                        }
                        .frame(height: 250)
                        .padding(.leading)
                        .padding(.trailing)
                    }
                }
                .padding(.top, 10)
                
                if UIDevice.current.userInterfaceIdiom == .phone {
                    VStack(alignment: .center) {
                        HStack {
                            Text("Minhas Pastas")
                                .font(.title2)
                            
                            Spacer()
                            
                            Button {
                                isShowingFolderInfoEditingSheet = true
                            } label: {
                                HStack {
                                    Image(systemName: "plus")
                                    Text("Nova Pasta")
                                }
                            }
                            .onChange(of: isShowingFolderInfoEditingSheet) { isShowing in
                                if isShowing == false {
                                    updateFolderList = true
                                    folderForEditingOnSheet = nil
                                }
                            }
                        }
                        
                        FolderList(updateFolderList: $updateFolderList, deleteFolderAid: $deleteFolderAid)
                    }
                    .padding(.top, 10)
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Coleções")
            .sheet(isPresented: $isShowingFolderInfoEditingSheet) {
                if let folder = folderForEditingOnSheet {
                    FolderInfoEditingView(isBeingShown: $isShowingFolderInfoEditingSheet, symbol: folder.symbol, folderName: folder.name, selectedBackgroundColor: folder.backgroundColor, isEditing: true, folderIdWhenEditing: folder.id)
                } else {
                    FolderInfoEditingView(isBeingShown: $isShowingFolderInfoEditingSheet, selectedBackgroundColor: "pastelPurple")
                }
            }
            .alert(isPresented: $deleteFolderAid.showAlert) {
                Alert(title: Text(deleteFolderAid.alertTitle), message: Text(deleteFolderAid.alertMessage), primaryButton: .destructive(Text("Apagar"), action: {
                    guard deleteFolderAid.folderIdForDeletion.isEmpty == false else {
                        return
                    }
                    try? database.deleteUserFolder(withId: deleteFolderAid.folderIdForDeletion)
                    updateFolderList = true
                }), secondaryButton: .cancel(Text("Cancelar")))
            }
            .onAppear {
                viewModel.reloadCollectionList(withCollections: getLocalCollections())
                //viewModel.reloadFolderList(withFolders: try? database.getAllUserFolders())
                //viewModel.donateActivity()
            }
            .padding(.bottom)
        }
    }
    
    private func getLocalCollections() -> [ContentCollection] {
        var array = [ContentCollection]()
        array.append(ContentCollection(title: "LGBT", imageURL: "http://blog.saude.mg.gov.br/wp-content/uploads/2021/06/28-06-lgbt.jpg"))
        array.append(ContentCollection(title: "Clássicos", imageURL: "https://www.avina.net/wp-content/uploads/2019/06/Confiamos-no-Brasil-e-nos-brasileiros-e-brasileiras.jpg"))
        array.append(ContentCollection(title: "Sérios", imageURL: "https://images.trustinnews.pt/uploads/sites/5/2019/10/tres-tabus-que-o-homem-atual-ja-ultrapassou-2.jpeg"))
        array.append(ContentCollection(title: "Invasão do Foro", imageURL: "https://piaui.folha.uol.com.br/wp-content/uploads/2022/09/imagem_foro_redes_data-RETRATOS.jpg"))
        array.append(ContentCollection(title: "Memes", imageURL: "https://i.ytimg.com/vi/r0jh29F6hSs/mqdefault.jpg"))
        return array
    }

}

struct CollectionsView_Previews: PreviewProvider {

    static var previews: some View {
        CollectionsView(isShowingFolderInfoEditingSheet: .constant(false))
    }

}
