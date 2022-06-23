import Combine
import UIKit

class FolderDetailViewViewModel: ObservableObject {

    @Published var sounds = [Sound]()
    @Published var hasSoundsToDisplay: Bool = false
    
    // Alerts
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    
    func reloadSoundList(withSoundIds soundIds: [String]?) {
        guard let soundIds = soundIds else {
            return
        }
        
        let sounds = soundData.filter({ soundIds.contains($0.id) })
        
        guard sounds.count > 0 else {
            return
        }
        
        self.sounds = sounds
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
    
    // MARK: - Alerts
    
    func showUnableToGetSoundAlert() {
        alertTitle = Shared.soundNotFoundAlertTitle
        alertMessage = Shared.soundNotFoundAlertMessage
        showAlert = true
    }
    
    func showPodcastDeletionConfirmation(podcastTitle: String) {
        alertTitle = String(format: "", podcastTitle)
        alertMessage = LocalizableStrings.MainView.ErrorMessages.podcastDeletionConfirmationMessage
        showAlert = true
    }

}
