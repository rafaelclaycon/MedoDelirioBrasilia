//
//  FolderListViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import Combine
import UIKit

class FolderListViewModel: ObservableObject {

    @Published var folders = [UserFolder]()
    @Published var hasFoldersToDisplay: Bool = false
    
    @Published var currentActivity: NSUserActivity? = nil
    
    // Alerts
//    @Published var alertTitle: String = ""
//    @Published var alertMessage: String = ""
//    @Published var showAlert: Bool = false
//    @Published var folderIdForDeletion: String = ""
    
    func reloadFolderList(withFolders outsideFolders: [UserFolder]?) {
        guard let actualFolders = outsideFolders, actualFolders.count > 0 else {
            return hasFoldersToDisplay = false
        }
        self.folders = actualFolders
        self.hasFoldersToDisplay = true
    }
    
    func donateActivity() {
        self.currentActivity = UserActivityWaiter.getDonatableActivity(withType: Shared.ActivityTypes.viewCollections, andTitle: "Ver e criar pastas de sons")
        self.currentActivity?.becomeCurrent()
    }
    
    // MARK: - Alerts
    
    /*func showFolderDeletionConfirmation(folderName: String, folderId: String) {
        alertTitle = "Apagar a Pasta \"\(folderName)\"?"
        alertMessage = "Os sons continuarão disponíveis no app, fora da pasta.\n\nEssa ação não pode ser desfeita."
        folderIdForDeletion = folderId
        showAlert = true
    }*/

}
