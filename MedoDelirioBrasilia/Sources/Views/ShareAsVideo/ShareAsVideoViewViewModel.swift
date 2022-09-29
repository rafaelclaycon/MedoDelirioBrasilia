import Combine
import UIKit

class ShareAsVideoViewViewModel: ObservableObject {

    var contentId: String
    private var contentTitle: String
    private var contentAuthor: String
    private var audioFilename: String
    
    @Published var image: UIImage
    @Published var includeSoundWarning: Bool = true
    
    @Published var isShowingProcessingView = false
    
    @Published var presentShareSheet = false
    @Published var pathToVideoFile = String.empty
    @Published var selectedSocialNetwork = VideoExportType.twitter.rawValue
    
    // Alerts
    @Published var alertTitle: String = .empty
    @Published var alertMessage: String = .empty
    @Published var showAlert: Bool = false
    
    init(contentId: String, contentTitle: String, contentAuthor: String, audioFilename: String) {
        self.contentId = contentId
        self.contentTitle = contentTitle
        self.contentAuthor = contentAuthor
        self.audioFilename = audioFilename
        self.image = UIImage()
        reloadImage()
    }
    
    func reloadImage() {
        if selectedSocialNetwork == VideoExportType.twitter.rawValue {
            image = VideoMaker.textToImage(drawText: contentTitle.uppercased(), drawAuthor: contentAuthor,
                                           inImage: UIImage(named: "square_video_background")!,
                                           atPoint: CGPoint(x: 80, y: 300))
        } else {
            image = VideoMaker.textToImage(drawText: contentTitle.uppercased(), drawAuthor: contentAuthor,
                                           inImage: UIImage(named: includeSoundWarning ? "9_16_video_background_with_warning" : "9_16_video_background_no_warning")!,
                                           atPoint: CGPoint(x: 80, y: 600))
        }
    }
    
    func createVideo() {
        DispatchQueue.main.async {
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
                try VideoMaker.createVideo(fromImage: self?.image ?? UIImage(),
                                           withDuration: audioDuration,
                                           andName: self?.contentTitle.withoutDiacritics() ?? .empty,
                                           soundFilepath: self?.audioFilename ?? .empty,
                                           exportType: VideoExportType(rawValue: self?.selectedSocialNetwork ?? VideoExportType.twitter.rawValue)!) { [weak self] videoPath, error in
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
