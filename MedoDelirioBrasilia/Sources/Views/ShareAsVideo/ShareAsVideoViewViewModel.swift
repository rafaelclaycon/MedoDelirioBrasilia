import Combine
import UIKit

class ShareAsVideoViewViewModel: ObservableObject {

    var contentId: String
    private var contentTitle: String
    private var audioFilename: String
    
    @Published var image: UIImage
    @Published var includeSoundWarning: Bool = true
    
    @Published var isShowingProcessingView = false
    @Published var processingViewMessage = String.empty
    
    @Published var presentShareSheet = false
    @Published var pathToVideoFile = String.empty
    @Published var selectedSocialNetwork = VideoExportType.twitter.rawValue
    
    // Alerts
    @Published var alertTitle: String = .empty
    @Published var alertMessage: String = .empty
    @Published var showAlert: Bool = false
    
    init(contentId: String, contentTitle: String, audioFilename: String) {
        self.contentId = contentId
        self.contentTitle = contentTitle
        self.audioFilename = audioFilename
        self.image = UIImage()
        reloadImage()
    }
    
    func reloadImage(hasUserSelectedImage: Bool = false, userSelectedImage: UIImage? = nil) {
        if hasUserSelectedImage {
            guard let userSelectedImage = userSelectedImage else { return }
            image = userSelectedImage
        } else {
            if selectedSocialNetwork == VideoExportType.twitter.rawValue {
                image = VideoMaker.textToImage(drawText: contentTitle.uppercased(),
                                               inImage: UIImage(named: "square_video_background")!,
                                               atPoint: CGPoint(x: 80, y: 300))
            } else {
                image = VideoMaker.textToImage(drawText: contentTitle.uppercased(),
                                               inImage: UIImage(named: includeSoundWarning ? "9_16_video_background_with_warning" : "9_16_video_background_no_warning")!,
                                               atPoint: CGPoint(x: 80, y: 600))
            }
        }
    }
    
    func resetImageToDefault() {
        reloadImage()
    }
    
    func createVideo(hasUserSelectedImage: Bool) {
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
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let audioDuration = VideoMaker.getAudioFileDuration(fileURL: url) else {
                DispatchQueue.main.async { [weak self] in
                    self?.isShowingProcessingView = false
                    self?.showOtherError(errorTitle: "Falha na Geração do Vídeo",
                                        errorBody: "Não foi possível obter a duração do áudio.")
                }
                return
            }
            
            do {
                let exportType: VideoExportType = hasUserSelectedImage ? .customImage : VideoExportType(rawValue: self?.selectedSocialNetwork ?? VideoExportType.twitter.rawValue)!
                
                try VideoMaker.createVideo(fromImage: self?.image ?? UIImage(),
                                           withDuration: audioDuration,
                                           andName: self?.contentTitle.withoutDiacritics() ?? .empty,
                                           soundFilepath: self?.audioFilename ?? .empty,
                                           exportType: exportType) { [weak self] videoPath, error in
                    guard let videoPath = videoPath else {
                        DispatchQueue.main.async { [weak self] in
                            self?.isShowingProcessingView = false
                            self?.showOtherError(errorTitle: "Falha na Geração do Vídeo",
                                                errorBody: "Não foi possível obter o caminho do vídeo.")
                        }
                        return
                    }
                    
                    DispatchQueue.main.async { [weak self] in
                        self?.isShowingProcessingView = false
                        self?.pathToVideoFile = videoPath
                        self?.presentShareSheet = true
                    }
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.isShowingProcessingView = false
                    self?.showOtherError(errorTitle: "Falha na Geração do Vídeo", errorBody: error.localizedDescription)
                }
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
