//
//  FolderInfoEditingView+ViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import Foundation

extension FolderInfoEditingView {

    @MainActor
    final class ViewModel: ObservableObject {

        @Published var folder: UserFolder

        // Alerts
        @Published var alertTitle: String = ""
        @Published var alertMessage: String = ""
        @Published var showAlert: Bool = false

        public let isEditing: Bool
        private let folderRepository: UserFolderRepositoryProtocol
        private let dismissSheet: () -> Void

        var saveCreateButtonIsDisabled: Bool {
            folder.symbol.isEmpty || folder.name.isEmpty
        }

        // MARK: - Initializer

        init(
            folder: UserFolder,
            folderRepository: UserFolderRepositoryProtocol,
            dismissSheet: @escaping () -> Void
        ) {
            self.folder = folder
            self.isEditing = !folder.name.isEmpty
            self.folderRepository = folderRepository
            self.dismissSheet = dismissSheet
        }
    }
}

// MARK: - User Actions

extension FolderInfoEditingView.ViewModel {

    func onPickedColorChanged(_ newColor: String) {
        folder.backgroundColor = newColor
    }

    func onSaveSelected() {
        guard checkIfMeetsAllRequirements() else { return }

        do {
            if isEditing {
                try folderRepository.update(folder)
            } else {
                try folderRepository.add(folder)
            }
        } catch {
            print(error.localizedDescription)
            showFolderSavingAlert(message: error.localizedDescription)
        }

        dismissSheet()
    }
}

// MARK: - Internal Functions

extension FolderInfoEditingView.ViewModel {

    private func checkIfMeetsAllRequirements() -> Bool {
        guard folder.symbol.isSingleEmoji else {
            showUnableToCreateFolderEmojiAlert(isEditing: isEditing)
            return false
        }
        return folder.name.count <= 25
    }

    // MARK: - Alerts

    private func showUnableToCreateFolderEmojiAlert(isEditing: Bool) {
        alertTitle = isEditing ? "Não É Possível Salvar a Pasta" : "Não É Possível Criar a Pasta"
        alertMessage = "O símbolo da pasta deve ser um emoji.\n\nPor favor, toque no retângulo colorido, troque para o teclado de emoji e escolha um dos emojis disponíveis."
        showAlert = true
    }

    private func showFolderSavingAlert(message: String) {
        alertTitle = isEditing ? "Não Foi Possível Salvar a Pasta" : "Não Foi Possível Criar a Pasta"
        alertMessage = message
        showAlert = true
    }
}
