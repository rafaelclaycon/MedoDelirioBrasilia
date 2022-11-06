//
//  CollectionsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 13/06/22.
//

import SwiftUI

struct CollectionsView: View {

    @StateObject private var viewModel = CollectionsViewViewModel()
    @Binding var isShowingFolderInfoEditingSheet: Bool
    @State private var folderForEditingOnSheet: UserFolder? = nil
    @State var updateFolderList: Bool = false
    @State var deleteFolderAid = DeleteFolderViewAid()
    @State var folderIdForEditing: String = .empty
    
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
                    
                    VStack(spacing: 10) {
                        Text("*Tá vindo!*")
                            .foregroundColor(.gray)
                            .font(.title3)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, UIDevice.current.userInterfaceIdiom == .phone ? 100 : 200)
                    
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        VStack(spacing: 10) {
                            Text("Procurando pelas pastas? Agora elas estão na aba Sons.")
                                .foregroundColor(.gray)
                                .font(.body)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 100)
                        .padding(.horizontal)
                    }
                    
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
            .onChange(of: folderIdForEditing) { folderIdForEditing in
                if folderIdForEditing.isEmpty == false {
                    folderForEditingOnSheet = try? database.getFolder(withId: folderIdForEditing)
                    guard folderForEditingOnSheet != nil else { return }
                    isShowingFolderInfoEditingSheet = true
                    self.folderIdForEditing = .empty
                }
            }
            .onAppear {
                //viewModel.reloadCollectionList(withCollections: getLocalCollections())
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
        CollectionsView(isShowingFolderInfoEditingSheet: .constant(false))
    }

}
