//
//  AddToFolderViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import SwiftUI

@Observable class AddToFolderViewModel {

    private var database: LocalDatabaseProtocol

    init(
        database injectedDatabase: LocalDatabaseProtocol
    ) {
        self.database = injectedDatabase
    }

    var folders = [UserFolder]()
    var hasFoldersToDisplay: Bool = false

    var soundsThatCanBeAdded: [AnyEquatableMedoContent]? = nil

    // Alerts
    var alertTitle: String = .empty
    var alertMessage: String = .empty
    var alertType: AlertType = .singleOption
    var showAlert: Bool = false
}

// MARK: - User Actions

extension AddToFolderViewModel {

    public func onExistingFolderSelected(
        folder: UserFolder,
        selectedContent: [AnyEquatableMedoContent]
    ) {
        do {
            soundsThatCanBeAdded = canBeAddedToFolder(content: selectedContent, folderId: folder.id)

            let soundsAlreadyInFolder = selectedContent.count - (soundsThatCanBeAdded?.count ?? 0)

            if selectedContent.count == soundsThatCanBeAdded?.count {
                try selectedContent.forEach { item in
                    try LocalDatabase.shared.insert(contentId: item.id, intoUserFolder: folder.id)
                }
                try UserFolderRepository().update(folder)

                folderName = "\(folder.symbol) \(folder.name)"
                pluralization = selectedSounds.count > 1 ? .plural : .singular
                hadSuccess = true
                isBeingShown = false
            } else if soundsAlreadyInFolder == 1, selectedContent.count == 1 {
                showSingleSoundAlredyInFolderAlert(folderName: folder.name)
            } else if soundsAlreadyInFolder == selectedContent.count {
                showAllSoundsAlredyInFolderAlert(folderName: folder.name)
            } else {
                folderForSomeSoundsAlreadyInFolder = folder
                showSomeSoundsAlreadyInFolderAlert(soundCountAlreadyInFolder: soundsAlreadyInFolder, folderName: folder.name)
            }
        } catch {
            showIssueSavingAlert(error.localizedDescription)
        }
    }
}

// MARK: - Internal Functions

extension AddToFolderViewModel {

    private func loadFolderList(withFolders outsideFolders: [UserFolder]?) {
        guard let actualFolders = outsideFolders, actualFolders.count > 0 else {
            return
        }
        self.folders = actualFolders
        self.hasFoldersToDisplay = true
    }

    private func canBeAddedToFolder(content: [AnyEquatableMedoContent], folderId: String) -> [AnyEquatableMedoContent] {
        var allowedList = [AnyEquatableMedoContent]()
        content.forEach { item in
            if soundIsNotYetOnFolder(folderId: folderId, contentId: item.id) {
                allowedList.append(item)
            }
        }
        return allowedList
    }

    private func soundIsNotYetOnFolder(folderId: String, contentId: String) -> Bool {
        var contentExistsInsideUserFolder = true
        do {
            contentExistsInsideUserFolder = try self.database.contentExistsInsideUserFolder(withId: folderId, contentId: contentId)
        } catch {
            return true
        }
        return contentExistsInsideUserFolder == false
    }

    // MARK: - Alerts

    private func showSingleSoundAlredyInFolderAlert(folderName: String) {
        alertTitle = "Já Adicionado"
        alertMessage = "Esse som já está na pasta \"\(folderName)\"."
        alertType = .singleOption
        showAlert = true
    }

    private func showSomeSoundsAlreadyInFolderAlert(soundCountAlreadyInFolder: Int, folderName: String) {
        if soundCountAlreadyInFolder == 1 {
            alertTitle = "1 Som Já Adicionado"
        } else {
            alertTitle = "\(soundCountAlreadyInFolder) Sons Já Adicionados"
        }
        alertMessage = "Deseja adicionar o restante à pasta \"\(folderName)\"?"
        alertType = .twoOptions
        showAlert = true
    }

    private func showAllSoundsAlredyInFolderAlert(folderName: String) {
        alertTitle = "Já Adicionados"
        alertMessage = "Todos os sons já estão na pasta \"\(folderName)\"."
        alertType = .singleOption
        showAlert = true
    }

    private func showIssueSavingAlert(_ message: String) {
        alertTitle = "Erro Adicionando Sons à Pasta"
        alertMessage = message
        alertType = .singleOption
        showAlert = true
    }
}
