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
    //@Binding var updateFolderList: Bool
    @State var deleteFolderAide = DeleteFolderViewAide()
    @State var folderIdForEditing: String = .empty
    @StateObject var deleteFolderAideiPhone = DeleteFolderViewAideiPhone() // Not used, here just so FolderList does not crash on iPad
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                FolderList(updateFolderList: .constant(false),
                           deleteFolderAide: $deleteFolderAide,
                           folderIdForEditing: $folderIdForEditing)
                    .environmentObject(deleteFolderAideiPhone)
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
        .alert(isPresented: $deleteFolderAide.showAlert) {
            Alert(title: Text(deleteFolderAide.alertTitle), message: Text(deleteFolderAide.alertMessage), primaryButton: .destructive(Text("Apagar"), action: {
                guard deleteFolderAide.folderIdForDeletion.isEmpty == false else {
                    return
                }
                try? database.deleteUserFolder(withId: deleteFolderAide.folderIdForDeletion)
                //updateFolderList = true
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
        AllFoldersiPadView(isShowingFolderInfoEditingSheet: .constant(false))
    }

}
