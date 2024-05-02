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
    @State var deleteFolderAide = DeleteFolderViewAide()
    @State var folderIdForEditing: String = .empty
    @StateObject var deleteFolderAideiPhone = DeleteFolderViewAideiPhone() // Not used, here just so FolderList does not crash on iPad
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                FolderList(
                    updateFolderList: $updateFolderList,
                    folderIdForEditing: $folderIdForEditing
                )
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
                HStack(spacing: 20) {
                    if CommandLine.arguments.contains("-SHOW_EXPORT_FOLDERS_OPTION") {
                        Button("Exportar Pastas") {
                            print("")
                        }
                    }

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
        }
        .alert(isPresented: $deleteFolderAide.showAlert) {
            Alert(title: Text(deleteFolderAide.alertTitle), message: Text(deleteFolderAide.alertMessage), primaryButton: .destructive(Text("Apagar"), action: {
                guard deleteFolderAide.folderIdForDeletion.isEmpty == false else {
                    return
                }
                try? LocalDatabase.shared.deleteUserFolder(withId: deleteFolderAide.folderIdForDeletion)
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

#Preview {
    AllFoldersiPadView(
        isShowingFolderInfoEditingSheet: .constant(false),
        updateFolderList: .constant(false)
    )
}
