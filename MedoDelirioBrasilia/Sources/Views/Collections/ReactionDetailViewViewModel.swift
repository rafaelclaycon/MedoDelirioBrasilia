//
//  ReactionDetailViewViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import Combine
import SwiftUI

class ReactionDetailViewViewModel: ObservableObject {

    @Published var state: GenericViewState
    
    @Published var sounds = [Sound]()
    @Published var hasSoundsToDisplay: Bool = false
    @Published var selectedSound: Sound? = nil
    
    // Sharing
    @Published var iPadShareSheet = ActivityViewController(activityItems: [URL(string: "https://www.apple.com")!])
    @Published var isShowingShareSheet: Bool = false
    @Published var shareBannerMessage: String = .empty
    @Published var displaySharedSuccessfullyToast: Bool = false
    
    // Alerts
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    @Published var alertType: AlertType = .singleOption
    
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
                self.sounds = self.getLocalCollections()
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
    
    private func getLocalCollections() -> [Sound] {
        var array = [Sound]()
        
        array.append(soundData.filter({ $0.id == "9CE6EAFC-3C19-424A-B358-AEE2733909F4" }).first!)
        array.append(soundData.filter({ $0.id == "4A4169BA-2B24-49CD-B5E9-001800412934" }).first!)
        array.append(soundData.filter({ $0.id == "4D0D833D-584C-439E-AC23-2D55D00794EA" }).first!)
        array.append(soundData.filter({ $0.id == "87666D4A-3439-4221-A1A0-D8BFF3F70202" }).first!)
        array.append(soundData.filter({ $0.id == "E8BDCFCF-611E-4DB8-ACAD-B1EECF0E3285" }).first!)
        array.append(soundData.filter({ $0.id == "CE548967-AC67-4439-BB18-694B2271FCF3" }).first!)
        
        return array
    }
    
    func reloadSoundList(withSoundIds soundIds: [String]?) {
        guard let soundIds = soundIds else {
            self.sounds = [Sound]()
            self.hasSoundsToDisplay = false
            return
        }
        
        let sounds = soundData.filter({ soundIds.contains($0.id) })
        
        guard sounds.count > 0 else {
            self.sounds = [Sound]()
            self.hasSoundsToDisplay = false
            return
        }
        
        self.sounds = sounds
        
        for i in stride(from: 0, to: self.sounds.count, by: 1) {
            self.sounds[i].authorName = authorData.first(where: { $0.id == self.sounds[i].authorId })?.name ?? Shared.unknownAuthor
        }
        
        self.hasSoundsToDisplay = true
    }
    
    func playSound(fromPath filepath: String) {
        guard filepath.isEmpty == false else {
            return
        }
        
        guard let path = Bundle.main.path(forResource: filepath, ofType: nil) else {
            return showUnableToGetSoundAlert()
        }
        let url = URL(fileURLWithPath: path)

        player = AudioPlayer(url: url, update: { state in
            //print(state?.activity as Any)
        })
        
        player?.togglePlay()
    }
    
    func shareSound(withPath filepath: String, andContentId contentId: String) {
        if UIDevice.current.userInterfaceIdiom == .phone {
            do {
                try Sharer.shareSound(withPath: filepath, andContentId: contentId) { didShareSuccessfully in
                    if didShareSuccessfully {
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
                            withAnimation {
                                self.shareBannerMessage = Shared.soundSharedSuccessfullyMessage
                                self.displaySharedSuccessfullyToast = true
                            }
                            TapticFeedback.success()
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                self.displaySharedSuccessfullyToast = false
                            }
                        }
                    }
                }
            } catch {
                showUnableToGetSoundAlert()
            }
        } else {
            guard filepath.isEmpty == false else {
                return
            }
            
            guard let path = Bundle.main.path(forResource: filepath, ofType: nil) else {
                return showUnableToGetSoundAlert()
            }
            let url = URL(fileURLWithPath: path)
            
            iPadShareSheet = ActivityViewController(activityItems: [url]) { activity, completed, items, error in
                if completed {
                    guard let activity = activity else {
                        return
                    }
                    let destination = ShareDestination.translateFrom(activityTypeRawValue: activity.rawValue)
                    Logger.logSharedSound(contentId: contentId, destination: destination, destinationBundleId: activity.rawValue)
                    
                    AppStoreReviewSteward.requestReviewBasedOnVersionAndCount()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
                        withAnimation {
                            self.shareBannerMessage = Shared.soundSharedSuccessfullyMessage
                            self.displaySharedSuccessfullyToast = true
                        }
                        TapticFeedback.success()
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            self.displaySharedSuccessfullyToast = false
                        }
                    }
                }
            }
            
            isShowingShareSheet = true
        }
    }
    
    func shareVideo(withPath filepath: String, andContentId contentId: String) {
        if UIDevice.current.userInterfaceIdiom == .phone {
            do {
                try Sharer.shareVideoFromSound(withPath: filepath, andContentId: contentId, shareSheetDelayInSeconds: 0.6) { didShareSuccessfully in
                    if didShareSuccessfully {
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
                            withAnimation {
                                self.shareBannerMessage = Shared.videoSharedSuccessfullyMessage
                                self.displaySharedSuccessfullyToast = true
                            }
                            TapticFeedback.success()
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                self.displaySharedSuccessfullyToast = false
                            }
                        }
                    }
                }
            } catch {
                showUnableToGetSoundAlert()
            }
        } else {
            guard filepath.isEmpty == false else {
                return
            }
            
            let url = URL(fileURLWithPath: filepath)
            
            iPadShareSheet = ActivityViewController(activityItems: [url]) { activity, completed, items, error in
                if completed {
                    self.isShowingShareSheet = false
                    
                    guard let activity = activity else {
                        return
                    }
                    let destination = ShareDestination.translateFrom(activityTypeRawValue: activity.rawValue)
                    Logger.logSharedVideoFromSound(contentId: contentId, destination: destination, destinationBundleId: activity.rawValue)
                    
                    AppStoreReviewSteward.requestReviewBasedOnVersionAndCount()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
                        withAnimation {
                            self.shareBannerMessage = Shared.videoSharedSuccessfullyMessage
                            self.displaySharedSuccessfullyToast = true
                        }
                        TapticFeedback.success()
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            self.displaySharedSuccessfullyToast = false
                        }
                    }
                }
            }
            
            isShowingShareSheet = true
        }
    }
    
    func removeSoundFromFolder(folderId: String, soundId: String) {
        try? database.deleteUserContentFromFolder(withId: folderId, contentId: soundId)
        reloadSoundList(withSoundIds: try? database.getAllSoundIdsInsideUserFolder(withId: folderId))
    }
    
    // MARK: - Alerts
    
    func showUnableToGetSoundAlert() {
        TapticFeedback.error()
        alertTitle = Shared.soundNotFoundAlertTitle
        alertMessage = Shared.soundNotFoundAlertMessage
        alertType = .singleOption
        showAlert = true
    }
    
    func showSoundRemovalConfirmation(soundTitle: String) {
        alertTitle = "Remover \"\(soundTitle)\"?"
        alertMessage = "O som continuará disponível fora da pasta."
        alertType = .twoOptions
        showAlert = true
    }

}
