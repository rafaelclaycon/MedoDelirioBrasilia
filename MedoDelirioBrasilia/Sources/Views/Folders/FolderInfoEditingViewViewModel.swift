import Combine
import UIKit

class FolderInfoEditingViewViewModel: ObservableObject {

    // Alerts
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    
    func checkIfMeetsAllRequirements(symbol: String, folderName: String) -> Bool {
        guard symbol.isSingleEmoji else {
            showUnableToCreateFolderEmojiAlert()
            return false
        }
        guard folderName.count <= 25 else {
            return false
        }
        
        return true
    }
    
    // MARK: - Alerts
    
    func showUnableToCreateFolderEmojiAlert() {
        alertTitle = "Não É Possível Criar a Pasta"
        alertMessage = "O símbolo da pasta deve ser um emoji.\n\nPor favor, toque no retângulo colorido, troque para o teclado de emoji e escolha um dos emojis disponíveis."
        showAlert = true
    }

}
