//
//  MyFoldersiPhoneView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 04/11/22.
//

import SwiftUI

struct MyFoldersiPhoneView: View {

    @State private var isShowingFolderInfoEditingSheet: Bool = false
    @State private var folderForEditingOnSheet: UserFolder? = nil
    @State var updateFolderList: Bool = false
    @State var deleteFolderAid = DeleteFolderViewAid()
    @State var folderIdForEditing: String = .empty
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                FolderList(updateFolderList: $updateFolderList,
                           deleteFolderAid: $deleteFolderAid,
                           folderIdForEditing: $folderIdForEditing)
            }
            .padding(.horizontal)
            .padding(.top, 7)
            .padding(.bottom, 18)
        }
        .navigationTitle("Minhas Pastas")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isShowingFolderInfoEditingSheet = true
                } label: {
                    HStack {
                        Image(systemName: "plus")
                    }
                }
            }
        }
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
    }

}

struct MyFoldersiPhoneView_Previews: PreviewProvider {

    static var previews: some View {
        MyFoldersiPhoneView()
    }

}
