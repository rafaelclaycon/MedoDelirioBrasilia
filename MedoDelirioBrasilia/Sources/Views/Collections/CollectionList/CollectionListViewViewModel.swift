//
//  CollectionListViewViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/10/22.
//

import Combine
import UIKit

class CollectionListViewViewModel: ObservableObject {

    @Published var state: GenericViewState
    @Published var collections = [ContentCollection]()
    
    init(state: GenericViewState) {
        self.state = state
    }
    
    func fetchCollections() {
        DispatchQueue.main.async {
            self.state = .loading
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            FolderResearchHelper.sendLogs { success in
                DispatchQueue.main.async {
                    if success {
                        self.state = .displayingData
                    } else {
                        self.state = .loadingError
                    }
                }
            }
        }
    }
    
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
