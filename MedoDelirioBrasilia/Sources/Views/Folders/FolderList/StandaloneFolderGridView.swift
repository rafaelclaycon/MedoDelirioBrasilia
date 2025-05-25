//
//  StandaloneFolderGridView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 19/07/22.
//

import SwiftUI

/// iPad and Mac only.
struct StandaloneFolderGridView: View {

    @Binding var folderForEditing: UserFolder?
    @Binding var updateFolderList: Bool
    let contentRepository: ContentRepositoryProtocol

    @State private var folderIdForEditing: String = ""
    @State private var showErrorDeletingAlert: Bool = false

    @State private var deleteFolderAide = DeleteFolderViewAide()

    // MARK: - View Body

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .center) {
                    FolderGrid(
                        viewModel: FolderGridViewModel(
                            userFolderRepository: UserFolderRepository(database: LocalDatabase.shared),
                            userSettings: UserSettings(),
                            appMemory: AppPersistentMemory.shared
                        ),
                        updateFolderList: $updateFolderList,
                        folderForEditing: $folderForEditing,
                        contentRepository: contentRepository,
                        containerSize: geometry.size
                    )
                    .environment(deleteFolderAide)
                }
                .padding(.horizontal, .spacing(.medium))
                .padding(.top, 7)
                .padding(.bottom, 18)
            }
            .navigationTitle("Pastas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack(spacing: 20) {
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
    }

    // MARK: - Functions

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

// MARK: - Preview

#Preview {
    NavigationStack {
        StandaloneFolderGridView(
            folderForEditing: .constant(nil),
            updateFolderList: .constant(false),
            contentRepository: FakeContentRepository()
        )
    }
}
