//
//  MyFoldersiPhoneView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 04/11/22.
//

import SwiftUI

struct MyFoldersiPhoneView: View {

    @State private var folderForEditing: UserFolder?
    @State private var updateFolderList: Bool = false // Does nothing, just here to satisfy FolderList :)
    @State private var currentSoundsListMode: SoundsListMode = .regular

    @EnvironmentObject var deleteFolderAide: DeleteFolderViewAide

    // MARK: - View Body

    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                FolderList(
                    updateFolderList: $updateFolderList,
                    folderForEditing: $folderForEditing
                )
            }
            .padding(.horizontal)
            .padding(.top, 7)
            .padding(.bottom, 18)
        }
        .navigationTitle("Minhas Pastas")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    folderForEditing = UserFolder.newFolder()
                } label: {
                    HStack {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(item: $folderForEditing) { folder in
            FolderInfoEditingView(
                folder: folder,
                folderRepository: UserFolderRepository(),
                dismissSheet: {
                    folderForEditing = nil
                    updateFolderList = true
                }
            )
        }
        .alert(isPresented: $deleteFolderAide.showAlert) {
            Alert(
                title: Text(deleteFolderAide.alertTitle),
                message: Text(deleteFolderAide.alertMessage),
                primaryButton: .destructive(Text("Apagar"), action: {
                    guard deleteFolderAide.folderIdForDeletion.isEmpty == false else {
                        return
                    }
                    try? LocalDatabase.shared.deleteUserFolder(withId: deleteFolderAide.folderIdForDeletion)
                    updateFolderList = true
                }),
                secondaryButton: .cancel(Text("Cancelar"))
            )
        }
    }
}

// MARK: - Preview

#Preview {
    MyFoldersiPhoneView()
}
