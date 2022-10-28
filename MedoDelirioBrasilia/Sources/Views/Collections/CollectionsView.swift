//
//  CollectionsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 13/06/22.
//

import SwiftUI

struct CollectionsView: View {

    @Binding var isShowingFolderInfoEditingSheet: Bool
    @State private var folderForEditingOnSheet: UserFolder? = nil
    @State var updateFolderList: Bool = false
    @State var deleteFolderAid = DeleteFolderViewAid()
    @State var folderIdForEditing: String = .empty
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                CollectionListView(viewModel: CollectionListViewViewModel(state: .loading))
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
                        
                        FolderList(updateFolderList: $updateFolderList,
                                   deleteFolderAid: $deleteFolderAid,
                                   folderIdForEditing: $folderIdForEditing)
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
            .onChange(of: folderIdForEditing) { folderIdForEditing in
                if folderIdForEditing.isEmpty == false {
                    folderForEditingOnSheet = try? database.getFolder(withId: folderIdForEditing)
                    guard folderForEditingOnSheet != nil else { return }
                    isShowingFolderInfoEditingSheet = true
                    self.folderIdForEditing = .empty
                }
            }
            .onAppear {
                //viewModel.donateActivity()
            }
            .padding(.bottom)
        }
    }

}

struct CollectionsView_Previews: PreviewProvider {

    static var previews: some View {
        CollectionsView(isShowingFolderInfoEditingSheet: .constant(false))
    }

}
