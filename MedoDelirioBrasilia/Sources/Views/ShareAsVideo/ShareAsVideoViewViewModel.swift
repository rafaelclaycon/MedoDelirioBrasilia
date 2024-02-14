//
//  ShareAsVideoViewViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 22/02/23.
//

import Combine
import PhotosUI

class ShareAsVideoViewViewModel: ObservableObject {

    var content: MedoContentProtocol
    var subtitle: String
    
    @Published var includeSoundWarning: Bool = true
    
    @Published var isShowingProcessingView = false
    
    @Published var shouldCloseView = false
    @Published var pathToVideoFile = String.empty
    @Published var selectedSocialNetwork = IntendedVideoDestination.twitter.rawValue
    
    // Alerts
    @Published var alertTitle: String = .empty
    @Published var alertMessage: String = .empty
    @Published var showAlert: Bool = false
    
    init(
        content: MedoContentProtocol,
        subtitle: String = ""
    ) {
        self.content = content
        self.subtitle = subtitle
    }
    
    func generateVideo(withImage image: UIImage, completion: @escaping (String?, VideoMakerError?) -> Void) {
        DispatchQueue.main.async {
            self.isShowingProcessingView = true
        }
        
        do {
            try VideoMaker.createVideo(
                from: content,
                with: image,
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
                self.showOtherError(
                    errorTitle: Shared.contentNotFoundAlertTitle(""),
                    errorBody: Shared.soundNotFoundAlertMessage
                )
            }
        } catch {
            DispatchQueue.main.async {
                self.isShowingProcessingView = false
                self.showOtherError(errorTitle: "Falha na Geração do Vídeo",
                                    errorBody: error.localizedDescription)
            }
        }
    }
    
    func saveVideoToPhotos(withImage image: UIImage, completion: @escaping (Bool, String?) -> Void) {
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
        
        generateVideo(withImage: image) { videoPath, error in
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
                // TODO: Deal with error.
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
