//
//  AllFoldersiPadView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 19/07/22.
//

import SwiftUI

/// iPad and Mac only.
struct AllFoldersiPadView: View {

    @Binding var isShowingFolderInfoEditingSheet: Bool
    @Binding var updateFolderList: Bool
    @State var deleteFolderAid = DeleteFolderViewAide()
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
        .navigationTitle("Pastas")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isShowingFolderInfoEditingSheet = true
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Nova Pasta")
                    }
                }
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
                isShowingFolderInfoEditingSheet = true
                self.folderIdForEditing = .empty
            }
        }
    }

}

struct AllFoldersiPadView_Previews: PreviewProvider {

    static var previews: some View {
        AllFoldersiPadView(isShowingFolderInfoEditingSheet: .constant(false), updateFolderList: .constant(false))
    }

}
