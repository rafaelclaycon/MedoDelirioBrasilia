import Combine
import UIKit

class FolderDetailViewViewModel: ObservableObject {

    @Published var sounds = [Sound]()
    @Published var hasSoundsToDisplay: Bool = false
    @Published var showConfirmationDialog = false
    @Published var soundForConfirmationDialog: Sound? = nil
    
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
            try Sharer.shareSound(withPath: filepath, andContentId: contentId)
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
