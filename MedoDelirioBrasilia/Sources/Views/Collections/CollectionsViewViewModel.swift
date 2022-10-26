//
//  CollectionsViewViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import Combine
import UIKit

class CollectionsViewViewModel: ObservableObject {

    @Published var collections = [ContentCollection]()
    
    // Alerts
//    @Published var alertTitle: String = ""
//    @Published var alertMessage: String = ""
//    @Published var showAlert: Bool = false
//    @Published var folderIdForDeletion: String = ""
    
    func reloadCollectionList(withCollections outsideCollections: [ContentCollection]?) {
        guard let actualCollections = outsideCollections, actualCollections.count > 0 else {
            return
        }
        self.collections = actualCollections
    }
    
    // MARK: - Alerts
    
//    func showFolderDeletionConfirmation(folderName: String, folderId: String) {
//        alertTitle = "Apagar a Pasta \"\(folderName)\"?"
//        alertMessage = "Os sons continuarão disponíveis no app, fora da pasta.\n\nEssa ação não pode ser desfeita."
//        folderIdForDeletion = folderId
//        showAlert = true
//    }

}
