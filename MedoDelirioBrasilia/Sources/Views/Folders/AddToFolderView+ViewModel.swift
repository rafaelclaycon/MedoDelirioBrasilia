//
//  AddToFolderView+ViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import Foundation

extension AddToFolderView {

    @MainActor
    final class ViewModel: ObservableObject {

        @Published var folders = [UserFolder]()
        @Published var hasFoldersToDisplay: Bool = false

        // Alerts
        @Published var alertTitle: String = .empty
        @Published var alertMessage: String = .empty
        @Published var alertType: AlertType = .singleOption
        @Published var showAlert: Bool = false

        private let selectedSounds: [Sound]
        private let repository: UserFolderRepositoryProtocol

        // MARK: - Computed Property

        var soundText: String {
            if selectedSounds.count == 1 {
                return "Som:  \(selectedSounds.first!.title)"
            } else {
                return "\(selectedSounds.count) sons selecionados"
            }
        }

        // MARK: - Initializer

        init(
            selectedSounds: [Sound],
            repository: UserFolderRepositoryProtocol = UserFolderRepository()
        ) {
            self.selectedSounds = selectedSounds
            self.repository = repository
        }
    }
}

// MARK: - User Actions

extension AddToFolderView.ViewModel {

    func onViewLoaded() {
        repository.
        viewModel.reloadFolderList(withFolders: try? LocalDatabase.shared.allFolders())
    }

    func onFolderSelected() {
        soundsThatCanBeAdded = viewModel.canBeAddedToFolder(sounds: selectedSounds, folderId: folder.id)

        let soundsAlreadyInFolder = selectedSounds.count - (soundsThatCanBeAdded?.count ?? 0)

        if selectedSounds.count == soundsThatCanBeAdded?.count {
            UserFolderRepository().add(sounds: selectedSounds, into: <#T##String#>)

            folderName = "\(folder.symbol) \(folder.name)"
            pluralization = selectedSounds.count > 1 ? .plural : .singular
            hadSuccess = true
            isBeingShown = false
        } else if soundsAlreadyInFolder == 1, selectedSounds.count == 1 {
            viewModel.showSingleSoundAlredyInFolderAlert(folderName: folder.name)
        } else if soundsAlreadyInFolder == selectedSounds.count {
            viewModel.showAllSoundsAlredyInFolderAlert(folderName: folder.name)
        } else {
            folderForSomeSoundsAlreadyInFolder = folder
            viewModel.showSomeSoundsAlreadyInFolderAlert(soundCountAlreadyInFolder: soundsAlreadyInFolder, folderName: folder.name)
        }
    }

    func onAddRemainingSelected() {
        soundsThatCanBeAdded?.forEach { sound in
            try? LocalDatabase.shared.insert(contentId: sound.id, intoUserFolder: folderForSomeSoundsAlreadyInFolder?.id ?? .empty)
        }

        if let folder = folderForSomeSoundsAlreadyInFolder {
            folderName = "\(folder.symbol) \(folder.name)"
        }
        pluralization = soundsThatCanBeAdded?.count ?? 0 > 1 ? .plural : .singular
        hadSuccess = true
        isBeingShown = false
    }
}

// MARK: - Internal Functions

extension AddToFolderView.ViewModel {

    func loadFolderList() {
        do {
            guard
                let folders = try repository.allFolders(),
                !folders.isEmpty
            else {
                self.folders = []
                hasFoldersToDisplay = false
                return
            }
            self.folders = folders
            hasFoldersToDisplay = true
        } catch  {
            self.folders = []
            hasFoldersToDisplay = false
        }
    }

    func canBeAddedToFolder(sounds: [Sound], folderId: String) -> [Sound] {
        var allowedList = [Sound]()
        sounds.forEach { sound in
            if soundIsNotYetOnFolder(folderId: folderId, contentId: sound.id) {
                allowedList.append(sound)
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

    func showSingleSoundAlredyInFolderAlert(folderName: String) {
        alertTitle = "Já Adicionado"
        alertMessage = "Esse som já está na pasta \"\(folderName)\"."
        alertType = .singleOption
        showAlert = true
    }

    func showSomeSoundsAlreadyInFolderAlert(soundCountAlreadyInFolder: Int, folderName: String) {
        if soundCountAlreadyInFolder == 1 {
            alertTitle = "1 Som Já Adicionado"
        } else {
            alertTitle = "\(soundCountAlreadyInFolder) Sons Já Adicionados"
        }
        alertMessage = "Deseja adicionar o restante à pasta \"\(folderName)\"?"
        alertType = .twoOptions
        showAlert = true
    }

    func showAllSoundsAlredyInFolderAlert(folderName: String) {
        alertTitle = "Já Adicionados"
        alertMessage = "Todos os sons já estão na pasta \"\(folderName)\"."
        alertType = .singleOption
        showAlert = true
    }
}
