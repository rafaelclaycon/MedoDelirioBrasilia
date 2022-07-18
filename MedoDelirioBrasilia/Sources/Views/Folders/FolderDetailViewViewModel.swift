import Combine
import SwiftUI

class FolderDetailViewViewModel: ObservableObject {

    @Published var sounds = [Sound]()
    @Published var hasSoundsToDisplay: Bool = false
    @Published var selectedSound: Sound? = nil
    
    // Sharing
    @Published var shouldDisplaySharedSuccessfullyToast: Bool = false
    
    // Alerts
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    @Published var alertType: AlertType = .singleOption
    
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
        do {
            try Sharer.shareSound(withPath: filepath, andContentId: contentId) { didShareSuccessfully in
                if didShareSuccessfully {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
                        withAnimation {
                            self.shouldDisplaySharedSuccessfullyToast = true
                        }
                        TapticFeedback.success()
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            self.shouldDisplaySharedSuccessfullyToast = false
                        }
                    }
                }
            }
        } catch {
            showUnableToGetSoundAlert()
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
