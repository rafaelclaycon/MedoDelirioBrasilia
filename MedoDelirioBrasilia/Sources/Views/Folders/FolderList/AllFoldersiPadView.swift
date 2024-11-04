//
//  AllFoldersiPadView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 19/07/22.
//

import SwiftUI

/// iPad and Mac only.
struct AllFoldersiPadView: View {

    @Binding var folderForEditing: UserFolder?
    @Binding var updateFolderList: Bool
    
    @State private var folderIdForEditing: String = ""
    @State private var showErrorDeletingAlert: Bool = false

    @StateObject var deleteFolderAide = DeleteFolderViewAide()

    // iPad Reactions Stuff
    @State private var exportDataString: String = ""
    @State private var isDataReadyToShow: Bool = false

    // MARK: - View Body

    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                if isDataReadyToShow {
                    TextEditor(text: $exportDataString)
                        .frame(minHeight: 300)  // Set a minimum height for the TextEditor
                        .padding()
                        .border(Color.gray, width: 1)  // Optionally add a border
                        //.disabled(true)  // Make it non-editable
                }

                FolderList(
                    updateFolderList: $updateFolderList,
                    folderForEditing: $folderForEditing
                )
                .environmentObject(deleteFolderAide)
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
                            exportFolders()
                        }
                    }

                    Button {
                        folderForEditing = UserFolder.newFolder()
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
            Alert(
                title: Text(deleteFolderAide.alertTitle),
                message: Text(deleteFolderAide.alertMessage),
                primaryButton: .destructive(
                    Text("Apagar"),
                    action: {
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

                    }
                ),
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

    // MARK: - Functions

    private func exportFolders() {
        do {
            let rawFolders = try LocalDatabase.shared.allFolders()
            var folders = rawFolders.map { UserFolderDTO(userFolder: $0) }

            for i in folders.indices {
                let folderContents = try LocalDatabase.shared.contentsInside(userFolder: folders[i].id)
                let contentIds = folderContents.map { $0.contentId }
                let sounds = try LocalDatabase.shared.sounds(withIds: contentIds)
                folders[i].sounds = sounds.map { $0.id }
            }

            if let jsonData = try? JSONEncoder().encode(folders), let jsonString = String(data: jsonData, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.exportDataString = jsonString
                    UIPasteboard.general.string = jsonString
                    self.isDataReadyToShow = true
                }
            }
        } catch {
            print("Erro ao tentar exportar as pastas para arquivo: \(error.localizedDescription)")
        }
    }

    private func verifyFile(at url: URL) -> Bool {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: url.path) {
            do {
                let attributes = try fileManager.attributesOfItem(atPath: url.path)
                if let fileSize = attributes[.size] as? NSNumber, fileSize.intValue > 0 {
                    return true
                }
            } catch {
                print("Error reading file attributes: \(error.localizedDescription)")
            }
        }
        return false
    }

    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

#Preview {
    AllFoldersiPadView(
        folderForEditing: .constant(nil),
        updateFolderList: .constant(false)
    )
}
