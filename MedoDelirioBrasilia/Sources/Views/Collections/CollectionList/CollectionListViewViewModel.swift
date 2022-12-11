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
            
            DispatchQueue.main.async {
                self.collections = self.getLocalCollections()
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
    
    func reloadCollectionList(withCollections outsideCollections: [ContentCollection]?) {
        guard let actualCollections = outsideCollections, actualCollections.count > 0 else {
            return
        }
        self.collections = actualCollections
    }
    
    private func getLocalCollections() -> [ContentCollection] {
        var array = [ContentCollection]()
        array.append(ContentCollection(title: "concordando", imageURL: "https://img.freepik.com/fotos-gratis/sim-muito-bom-negro-sorrindo-mostrando-o-polegar-em-aprovacao-gostando-e-concordando-homem-afro-americano-elogia-o-bom-trabalho-recomendando-venda-de-pe-sobre-fundo-branco_176420-46747.jpg"))
        array.append(ContentCollection(title: "não quero", imageURL: "https://www.avina.net/wp-content/uploads/2019/06/Confiamos-no-Brasil-e-nos-brasileiros-e-brasileiras.jpg"))
        array.append(ContentCollection(title: "sei lá!", imageURL: "https://uploads.spiritfanfiction.com/historias/capas/201811/sei-la-14950203-231120181036.jpg"))
        array.append(ContentCollection(title: "uhuuu!", imageURL: "https://i.scdn.co/image/0a32a3b9a4f798833f1c10aac18197f7b119e758"))
        array.append(ContentCollection(title: "ok", imageURL: "https://i.ytimg.com/vi/r0jh29F6hSs/mqdefault.jpg"))
        array.append(ContentCollection(title: "por favor", imageURL: "https://i.ytimg.com/vi/r0jh29F6hSs/mqdefault.jpg"))
        array.append(ContentCollection(title: "não", imageURL: "https://st4.depositphotos.com/2024219/21987/i/450/depositphotos_219878118-stock-photo-young-girl-yellow-sweater-blue.jpg"))
        array.append(ContentCollection(title: "sério?", imageURL: "https://i.ytimg.com/vi/r0jh29F6hSs/mqdefault.jpg"))
        
        array.append(ContentCollection(title: "LGBTQIAP+", imageURL: "http://blog.saude.mg.gov.br/wp-content/uploads/2021/06/28-06-lgbt.jpg"))
        
        return array
    }
    
    // MARK: - Alerts
    
//    func showFolderDeletionConfirmation(folderName: String, folderId: String) {
//        alertTitle = "Apagar a Pasta \"\(folderName)\"?"
//        alertMessage = "Os sons continuarão disponíveis no app, fora da pasta.\n\nEssa ação não pode ser desfeita."
//        folderIdForDeletion = folderId
//        showAlert = true
//    }

}
