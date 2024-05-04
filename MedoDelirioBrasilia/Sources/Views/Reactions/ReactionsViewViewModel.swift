//
//  CollectionsViewViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import Foundation
import Combine

class ReactionsViewViewModel: ObservableObject {

    @Published var state: LoadingState<Reaction> = .loading

    // Alerts
//    @Published var alertTitle: String = ""
//    @Published var alertMessage: String = ""
//    @Published var showAlert: Bool = false
//    @Published var folderIdForDeletion: String = ""
    
    // MARK: - Functions

    func loadList() async {
        state = .loading

        do {
            let url = URL(string: NetworkRabbit.shared.serverPath + "v4/reactions")!
            let reactions: [Reaction] = try await NetworkRabbit.get(from: url)
            state = .loaded(reactions)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    // MARK: - Alerts
    
//    func showFolderDeletionConfirmation(folderName: String, folderId: String) {
//        alertTitle = "Apagar a Pasta \"\(folderName)\"?"
//        alertMessage = "Os sons continuarão disponíveis no app, fora da pasta.\n\nEssa ação não pode ser desfeita."
//        folderIdForDeletion = folderId
//        showAlert = true
//    }

}
