import Combine
import UIKit

class ShareAsVideoViewViewModel: ObservableObject {

    // Alerts
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    
    func createVideo(audioFilename: String, image: UIImage) {
        guard audioFilename.isEmpty == false else {
            return
        }
        
        guard let path = Bundle.main.path(forResource: audioFilename, ofType: nil) else {
            fatalError("unableToFindSoundFile")
        }
        let url = URL(fileURLWithPath: path)
        
        guard let audioDuration = VideoMaker.getAudioFileDuration(fileURL: url) else {
            return
        }
        
        VideoMaker.createVideo(fromImage: image, duration: audioDuration)
    }
    
    // MARK: - Alerts
    
    func showUnableToCreateFolderEmojiAlert(isEditing: Bool) {
        alertTitle = isEditing ? "Não É Possível Salvar a Pasta" : "Não É Possível Criar a Pasta"
        alertMessage = "O símbolo da pasta deve ser um emoji.\n\nPor favor, toque no retângulo colorido, troque para o teclado de emoji e escolha um dos emojis disponíveis."
        showAlert = true
    }

}
