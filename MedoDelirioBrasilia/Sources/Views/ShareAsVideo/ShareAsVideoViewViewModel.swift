//
//  ShareAsVideoViewViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 22/02/23.
//

import Combine
import PhotosUI

class ShareAsVideoViewViewModel: ObservableObject {

    var content: AnyEquatableMedoContent
    var subtitle: String
    private let type: ContentType
    
    @Published var includeSoundWarning: Bool = true
    @Published var isShowingProcessingView = false

    @Published var shouldCloseView = false
    @Published var pathToVideoFile = ""
    @Published var selectedSocialNetwork = IntendedVideoDestination.twitter.rawValue

    // Alerts
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false

    // MARK: - Initializer

    init(
        content: AnyEquatableMedoContent,
        subtitle: String = "",
        contentType: ContentType
    ) {
        self.content = content
        self.subtitle = subtitle
        self.type = contentType
    }

    // MARK: - Functions

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
                    errorBody: Shared.contentNotFoundAlertMessage
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

                Logger.shared.logShared(
                    self.type,
                    contentId: self.content.id,
                    destination: .other,
                    destinationBundleId: Shared.BundleIds.applePhotosApp
                )

                completion(true, videoPath)
            }
        }
    }
    
    func showOtherError(errorTitle: String, errorBody: String) {
        alertTitle = errorTitle
        alertMessage = errorBody
        showAlert = true
    }
}
