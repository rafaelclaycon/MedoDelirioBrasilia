import Combine
import UIKit

class ShareAsVideoViewViewModel: ObservableObject {

    @Published var isShowingProcessingView = false
    @Published var processingViewMessage = String.empty
    @Published var isPresentingShareSheet = false
    @Published var pathToVideoFile = String.empty
    
    // Alerts
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    
    func createVideo(audioFilename: String, image: UIImage) {
        DispatchQueue.main.async {
            self.processingViewMessage = "Gerando vídeo..."
            self.isShowingProcessingView = true
        }
        
        guard audioFilename.isEmpty == false else {
            DispatchQueue.main.async {
                self.isShowingProcessingView = false
                self.showOtherError(errorTitle: Shared.soundNotFoundAlertTitle,
                                    errorBody: Shared.soundNotFoundAlertMessage)
            }
            return
        }
        
        guard let path = Bundle.main.path(forResource: audioFilename, ofType: nil) else {
            DispatchQueue.main.async {
                self.isShowingProcessingView = false
                self.showOtherError(errorTitle: Shared.soundNotFoundAlertTitle,
                                    errorBody: Shared.soundNotFoundAlertMessage)
            }
            return
        }
        
        let url = URL(fileURLWithPath: path)
        
        guard let audioDuration = VideoMaker.getAudioFileDuration(fileURL: url) else {
            DispatchQueue.main.async {
                self.isShowingProcessingView = false
                self.showOtherError(errorTitle: "Falha na Geração do Vídeo",
                                    errorBody: "Não foi possível obter a duração do áudio.")
            }
            return
        }
        do {
            try VideoMaker.createVideo(fromImage: image, duration: audioDuration) { [weak self] videoPath in
                guard let videoPath = videoPath else {
                    DispatchQueue.main.async {
                        self?.isShowingProcessingView = false
                        self?.showOtherError(errorTitle: "Falha na Geração do Vídeo",
                                            errorBody: "Não foi possível obter o caminho do vídeo.")
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    self?.isShowingProcessingView = false
                    self?.pathToVideoFile = videoPath
                    self?.isPresentingShareSheet = true
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.isShowingProcessingView = false
                self.showOtherError(errorTitle: "Falha na Geração do Vídeo", errorBody: error.localizedDescription)
            }
        }
    }
    
    // MARK: - Alerts
    
    private func showOtherError(errorTitle: String, errorBody: String) {
        alertTitle = errorTitle
        alertMessage = errorBody
        showAlert = true
    }

}
