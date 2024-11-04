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
    @State private var showErrorDeletingAlert: Bool = false

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
                    guard !deleteFolderAide.folderIdForDeletion.isEmpty else {
                        return
                    }

                    do {
                        try LocalDatabase.shared.deleteUserFolder(withId: deleteFolderAide.folderIdForDeletion)

                        // Need to update folder hashes so SyncManager knows about the change on next sync.
                        let provider = FolderResearchProvider(
                            userSettings: UserSettings(),
                            appMemory: AppPersistentMemory(),
                            localDatabase: LocalDatabase(),
                            repository: FolderResearchRepository()
                        )
                        try provider.saveCurrentHashesToAppMemory()

                        updateFolderList = true
                    } catch {
                        showErrorDeletingAlert = true
                    }
                }),
                secondaryButton: .cancel(Text("Cancelar"))
            )
        }
        .alert(
            "Erro Ao Tentar Apagar a Pasta",
            isPresented: $showErrorDeletingAlert
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Tente novamente mais tarde. Se o erro persisir, por favor, envie um e-mail para o desenvolvedor.")
        }
    }
}

// MARK: - Preview

#Preview {
    MyFoldersiPhoneView()
}
