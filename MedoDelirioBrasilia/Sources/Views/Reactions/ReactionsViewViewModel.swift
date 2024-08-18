//
//  CollectionsViewViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import SwiftUI
import Combine

class ReactionsViewViewModel: ObservableObject {

    @Published var state: LoadingState<Reaction> = .loading

    @Published var isShowingSheet: Bool = false

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
            var reactions: [Reaction] = try await NetworkRabbit.get(from: url)
            reactions.sort(by: { $0.position < $1.position })

            DispatchQueue.main.async {
                self.state = .loaded(reactions)
            }

            Analytics.send(
                originatingScreen: "ReactionsView",
                action: "didViewReactionsTab"
            )
        } catch {
            DispatchQueue.main.async {
                self.state = .error(error.localizedDescription)
            }
        }
    }
}
