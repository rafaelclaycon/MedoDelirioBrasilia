import Combine
import UIKit

class SongsViewViewModel: ObservableObject {
    
    @Published var songs = [Song]()
    @Published var sortOption: Int = 0
    @Published var nowPlayingKeeper = Set<String>()
    
    @Published var currentActivity: NSUserActivity? = nil
    
    func reloadList() {
        if UserSettings.getShowOffensiveSounds() {
            self.songs = songData
        } else {
            self.songs = songData.filter({ $0.isOffensive == false })
        }
        
        self.sortOption = 0 //UserSettings.getArchiveSortOption()
        
        if self.songs.count > 0 {
            self.songs.sort(by: { $0.title.withoutDiacritics() < $1.title.withoutDiacritics() })
        }
    }
    
    func playSong(fromPath filepath: String) {
        guard filepath.isEmpty == false else {
            return
        }
        
        guard let path = Bundle.main.path(forResource: filepath, ofType: nil) else {
            return
        }
        let url = URL(fileURLWithPath: path)
        
        player = AudioPlayer(url: url, update: { [weak self] state in
            //print(state?.activity as Any)
            if state?.activity == .stopped {
                self?.nowPlayingKeeper.removeAll()
            }
        })
        
        player?.togglePlay()
    }

    func shareSong(withPath filepath: String) {
        guard filepath.isEmpty == false else {
            return
        }
        
        guard let path = Bundle.main.path(forResource: filepath, ofType: nil) else {
            return
        }
        let url = URL(fileURLWithPath: path)
        
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.rootViewController?.present(activityVC, animated: true, completion: nil)
        }
        activityVC.completionWithItemsHandler = { activity, completed, items, error in
            if completed {
//                guard let activity = activity else {
//                    return
//                }
//                let destination = ShareDestination.translateFrom(activityTypeRawValue: activity.rawValue)
//                Logger.logSharedSound(contentId: contentId, destination: destination, destinationBundleId: activity.rawValue)
                
                AppStoreReviewSteward.requestReviewBasedOnVersionAndCount()
            }
        }
    }
    
    func donateActivity() {
        self.currentActivity = UserActivityWaiter.getDonatableActivity(withType: Shared.playAndShareSongsActivityTypeName, andTitle: "Tocar e compartilhar músicas")
        self.currentActivity?.becomeCurrent()
    }

}
