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
    @State private var updateFolderList: Bool = false // Does nothing, just here to satisfy FolderList :)
    @State private var folderIdForEditing: String = .empty
    @State private var currentSoundsListMode: SoundsListMode = .regular

    @EnvironmentObject var deleteFolderAide: DeleteFolderViewAideiPhone

    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                FolderList(
                    updateFolderList: $updateFolderList,
                    folderIdForEditing: $folderIdForEditing
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
                    isShowingFolderInfoEditingSheet = true
                } label: {
                    HStack {
                        Image(systemName: "plus")
                    }
                }
                .onChange(of: isShowingFolderInfoEditingSheet) { isShowing in
                    if isShowing == false {
                        updateFolderList = true
                        folderForEditingOnSheet = nil
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingFolderInfoEditingSheet) {
            if let folder = folderForEditingOnSheet {
                FolderInfoEditingView(isBeingShown: $isShowingFolderInfoEditingSheet, symbol: folder.symbol, folderName: folder.name, selectedBackgroundColor: folder.backgroundColor, isEditing: true, folderIdWhenEditing: folder.id)
            } else {
                FolderInfoEditingView(isBeingShown: $isShowingFolderInfoEditingSheet, selectedBackgroundColor: Shared.Folders.defaultFolderColor)
            }
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
        .onChange(of: folderIdForEditing) { folderIdForEditing in
            if folderIdForEditing.isEmpty == false {
                folderForEditingOnSheet = try? LocalDatabase.shared.getFolder(withId: folderIdForEditing)
                guard folderForEditingOnSheet != nil else { return }
                isShowingFolderInfoEditingSheet = true
                self.folderIdForEditing = .empty
            }
        }
    }

}

#Preview {
    MyFoldersiPhoneView()
}
