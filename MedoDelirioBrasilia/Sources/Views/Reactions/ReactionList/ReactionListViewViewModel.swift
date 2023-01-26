//
//  ReactionListViewViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/10/22.
//

import Combine
import UIKit

class ReactionListViewViewModel: ObservableObject {

    @Published var state: GenericViewState
    @Published var reactions = [Reaction]()
    
    init(state: GenericViewState) {
        self.state = state
    }
    
    func fetchReactions() {
        DispatchQueue.main.async {
            self.state = .loading
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.reactions = reactionData
                self.state = .displayingData
            }
            
//            FolderResearchHelper.sendLogs { success in
//                DispatchQueue.main.async {
//                    if success {
//                        self.state = .displayingData
//                    } else {
//                        self.state = .loadingError
//                    }
//                }
//            }
        }
    }
    
    // Alerts
//    @Published var alertTitle: String = ""
//    @Published var alertMessage: String = ""
//    @Published var showAlert: Bool = false
//    @Published var folderIdForDeletion: String = ""
    
    func reloadCollectionList(withCollections outsideCollections: [Reaction]?) {
        guard let actualCollections = outsideCollections, actualCollections.count > 0 else {
            return
        }
        self.reactions = actualCollections
    }
    
    // MARK: - Alerts
    
//    func showFolderDeletionConfirmation(folderName: String, folderId: String) {
//        alertTitle = "Apagar a Pasta \"\(folderName)\"?"
//        alertMessage = "Os sons continuarão disponíveis no app, fora da pasta.\n\nEssa ação não pode ser desfeita."
//        folderIdForDeletion = folderId
//        showAlert = true
//    }

}
