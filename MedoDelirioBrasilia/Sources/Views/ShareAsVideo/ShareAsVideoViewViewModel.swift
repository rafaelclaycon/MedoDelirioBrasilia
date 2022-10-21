import Combine
import UIKit
import PhotosUI

class ShareAsVideoViewViewModel: ObservableObject {

    var contentId: String
    private var contentTitle: String
    private var audioFilename: String
    
    @Published var image: UIImage
    @Published var includeSoundWarning: Bool = true
    
    @Published var isShowingProcessingView = false
    
    @Published var shouldCloseView = false
    @Published var pathToVideoFile = String.empty
    @Published var selectedSocialNetwork = IntendedVideoDestination.twitter.rawValue
    
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
    
    func reloadImage() {
        if selectedSocialNetwork == IntendedVideoDestination.twitter.rawValue {
            image = VideoMaker.textToImage(drawText: contentTitle.uppercased(),
                                           inImage: UIImage(named: "square_video_background")!,
                                           atPoint: CGPoint(x: 80, y: 300))
        } else {
            image = VideoMaker.textToImage(drawText: contentTitle.uppercased(),
                                           inImage: UIImage(named: includeSoundWarning ? "9_16_video_background_with_warning" : "9_16_video_background_no_warning")!,
                                           atPoint: CGPoint(x: 80, y: 600))
        }
    }
    
    func generateVideo(completion: @escaping (String?, VideoMakerError?) -> Void) {
        DispatchQueue.main.async {
            self.isShowingProcessingView = true
        }
        
        do {
            try VideoMaker.createVideo(from: audioFilename,
                                       with: image,
                                       contentTitle: contentTitle.withoutDiacritics(),
                                       exportType: IntendedVideoDestination(rawValue: selectedSocialNetwork)!
            ) { videoPath, error in
                guard error == nil else {
                    return completion(nil, error)
                }
                completion(videoPath, nil)
            }
        } catch VideoMakerError.soundFilepathIsEmpty {
            DispatchQueue.main.async {
                self.isShowingProcessingView = false
                self.showOtherError(errorTitle: Shared.soundNotFoundAlertTitle,
                                    errorBody: Shared.soundNotFoundAlertMessage)
            }
        } catch {
            DispatchQueue.main.async {
                self.isShowingProcessingView = false
                self.showOtherError(errorTitle: "Falha na Geração do Vídeo",
                                    errorBody: error.localizedDescription)
            }
        }
    }
    
    func saveVideoToPhotos(completion: @escaping (Bool, String?) -> Void) {
        DispatchQueue.main.async {
            self.isShowingProcessingView = true
        }
        
        // Create video album
//        let photos = PHPhotoLibrary.authorizationStatus()
//        if photos == .notDetermined {
//            PHPhotoLibrary.requestAuthorization({status in
//                if status == .authorized {
//                    CustomPhotoAlbum.sharedInstance.requestAuthorizationHandler(status: .authorized)
//                } else {
//                    print(status)
//                }
//            })
//        } else {
//            CustomPhotoAlbum.sharedInstance.requestAuthorizationHandler(status: .authorized)
//        }
        
        generateVideo { videoPath, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.isShowingProcessingView = false
                    self.showOtherError(errorTitle: "Falha na Geração do Vídeo",
                                        errorBody: error.localizedDescription)
                }
                completion(false, nil)
                return
            }
            guard let videoPath = videoPath else {
                completion(false, nil)
                return
            }
            CustomPhotoAlbum.sharedInstance.save(video: URL(fileURLWithPath: videoPath)) { success, error in
                print("Saved!")
                DispatchQueue.main.async {
                    self.isShowingProcessingView = false
                }
                completion(true, videoPath)
            }
        }
    }
    
    // MARK: - Alerts
    
    func showOtherError(errorTitle: String, errorBody: String) {
        alertTitle = errorTitle
        alertMessage = errorBody
        showAlert = true
    }

}
