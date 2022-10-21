//
//  FolderInfoEditingViewViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import Combine
import UIKit

class FolderInfoEditingViewViewModel: ObservableObject {

    // Alerts
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    
    func checkIfMeetsAllRequirements(symbol: String, folderName: String, isEditing: Bool) -> Bool {
        guard symbol.isSingleEmoji else {
            showUnableToCreateFolderEmojiAlert(isEditing: isEditing)
            return false
        }
        guard folderName.count <= 25 else {
            return false
        }
        
        return true
    }
    
    // MARK: - Alerts
    
    func showUnableToCreateFolderEmojiAlert(isEditing: Bool) {
        alertTitle = isEditing ? "Não É Possível Salvar a Pasta" : "Não É Possível Criar a Pasta"
        alertMessage = "O símbolo da pasta deve ser um emoji.\n\nPor favor, toque no retângulo colorido, troque para o teclado de emoji e escolha um dos emojis disponíveis."
        showAlert = true
    }

}
