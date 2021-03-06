import Combine
import SwiftUI
import UIKit

class SongsViewViewModel: ObservableObject {

    @Published var songs = [Song]()
    
    @Published var sortOption: Int = 0
    @Published var nowPlayingKeeper = Set<String>()
    @Published var showEmailAppPicker_suggestChangeConfirmationDialog = false
    @Published var selectedSong: Song? = nil
    
    @Published var currentActivity: NSUserActivity? = nil
    
    // Sharing
    @Published var iPadShareSheet = ActivityViewController(activityItems: [URL(string: "https://www.apple.com")!])
    @Published var isShowingShareSheet: Bool = false
    @Published var shouldDisplaySharedSuccessfullyToast: Bool = false
    
    func reloadList(withSongs allSongs: [Song],
                    allowSensitiveContent: Bool,
                    sortedBy sortOption: SongSortOption) {
        var songsCopy = allSongs
        
        if allowSensitiveContent == false {
            songsCopy = songsCopy.filter({ $0.isOffensive == false })
        }
        
        self.songs = songsCopy
        
        self.sortOption = sortOption.rawValue
        
        switch sortOption {
        case .titleAscending:
            sortSongsInPlaceByTitleAscending()
        case .dateAddedDescending:
            sortSongsInPlaceByDateAddedDescending()
        }
    }
    
    private func sortSongsInPlaceByTitleAscending() {
        self.songs.sort(by: { $0.title.withoutDiacritics() < $1.title.withoutDiacritics() })
    }
    
    private func sortSongsInPlaceByDateAddedDescending() {
        self.songs.sort(by: { $0.dateAdded ?? Date() > $1.dateAdded ?? Date() })
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

    func shareSong(withPath filepath: String, andContentId contentId: String) {
        if UIDevice.current.userInterfaceIdiom == .phone {
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
                print("Unable to get song.")
            }
        } else {
            guard filepath.isEmpty == false else {
                return
            }
            
            guard let path = Bundle.main.path(forResource: filepath, ofType: nil) else {
                return print("Unable to get song.")
            }
            let url = URL(fileURLWithPath: path)
            
            iPadShareSheet = ActivityViewController(activityItems: [url]) { activity, completed, items, error in
                if completed {
                    self.isShowingShareSheet = false
                    
                    guard let activity = activity else {
                        return
                    }
                    let destination = ShareDestination.translateFrom(activityTypeRawValue: activity.rawValue)
                    Logger.logSharedSound(contentId: contentId, destination: destination, destinationBundleId: activity.rawValue)
                    
                    AppStoreReviewSteward.requestReviewBasedOnVersionAndCount()
                    
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
            
            isShowingShareSheet = true
        }
    }
    
    func donateActivity() {
        self.currentActivity = UserActivityWaiter.getDonatableActivity(withType: Shared.ActivityTypes.playAndShareSongs, andTitle: "Tocar e compartilhar m??sicas")
        self.currentActivity?.becomeCurrent()
    }

}
