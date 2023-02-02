//
//  AddToFolderViewViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import Combine

class AddToFolderViewViewModel: ObservableObject {

    private var database: LocalDatabaseProtocol
    
    init(database injectedDatabase: LocalDatabaseProtocol) {
        self.database = injectedDatabase
    }
    
    @Published var folders = [UserFolder]()
    @Published var hasFoldersToDisplay: Bool = false
    
    // Alerts
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    
    func reloadFolderList(withFolders outsideFolders: [UserFolder]?) {
        guard let actualFolders = outsideFolders, actualFolders.count > 0 else {
            return
        }
        self.folders = actualFolders
        self.hasFoldersToDisplay = true
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
    
    func soundIsNotYetOnFolder(folderId: String, contentId: String) -> Bool {
        var contentExistsInsideUserFolder = true
        do {
            contentExistsInsideUserFolder = try self.database.contentExistsInsideUserFolder(withId: folderId, contentId: contentId)
        } catch {
            return true
        }
        return contentExistsInsideUserFolder == false
    }
    
    // MARK: - Alerts
    
    func showSoundAlredyInFolderAlert(folderName: String) {
        alertTitle = "Já Adicionado"
        alertMessage = "Esse som já está na pasta \"\(folderName)\"."
        showAlert = true
    }

}
