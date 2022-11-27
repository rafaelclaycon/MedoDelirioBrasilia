//
//  SongsViewViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 19/05/22.
//

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
    #if os(iOS)
    @Published var iPadShareSheet = ActivityViewController(activityItems: [URL(string: "https://www.apple.com")!])
    #endif
    @Published var isShowingShareSheet: Bool = false
    @Published var shareBannerMessage: String = .empty
    @Published var displaySharedSuccessfullyToast: Bool = false
    
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
        case .durationDescending:
            sortSongsInPlaceByDurationDescending()
        case .durationAscending:
            sortSongsInPlaceByDurationAscending()
        }
    }
    
    private func sortSongsInPlaceByTitleAscending() {
        self.songs.sort(by: { $0.title.withoutDiacritics() < $1.title.withoutDiacritics() })
    }
    
    private func sortSongsInPlaceByDateAddedDescending() {
        self.songs.sort(by: { $0.dateAdded ?? Date() > $1.dateAdded ?? Date() })
    }
    
    private func sortSongsInPlaceByDurationDescending() {
        self.songs.sort(by: { $0.duration > $1.duration })
    }
    
    private func sortSongsInPlaceByDurationAscending() {
        self.songs.sort(by: { $0.duration < $1.duration })
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
                                self.shareBannerMessage = Shared.songSharedSuccessfullyMessage
                                self.displaySharedSuccessfullyToast = true
                            }
                            ////TapticFeedback.success()
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                self.displaySharedSuccessfullyToast = false
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
            
            #if os(iOS)
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
                            self.shareBannerMessage = Shared.songSharedSuccessfullyMessage
                            self.displaySharedSuccessfullyToast = true
                        }
                        //TapticFeedback.success()
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            self.displaySharedSuccessfullyToast = false
                        }
                    }
                }
            }
            #endif
            
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
                            //TapticFeedback.success()
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                self.displaySharedSuccessfullyToast = false
                            }
                        }
                    }
                    
                    WallE.deleteAllVideoFilesFromDocumentsDir()
                }
            } catch {
                print("Unable to get song.")
            }
        } else {
            guard filepath.isEmpty == false else {
                return
            }
            
            let url = URL(fileURLWithPath: filepath)
            
            #if os(iOS)
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
                        //TapticFeedback.success()
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            self.displaySharedSuccessfullyToast = false
                        }
                    }
                }
                
                WallE.deleteAllVideoFilesFromDocumentsDir()
            }
            #endif
            
            isShowingShareSheet = true
        }
    }
    
    func showVideoSavedSuccessfullyToast() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
            withAnimation {
                self.shareBannerMessage = "Vídeo salvo com sucesso."
                self.displaySharedSuccessfullyToast = true
            }
            //TapticFeedback.success()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                self.displaySharedSuccessfullyToast = false
            }
        }
    }
    
    func donateActivity() {
        self.currentActivity = UserActivityWaiter.getDonatableActivity(withType: Shared.ActivityTypes.playAndShareSongs, andTitle: "Ouvir e compartilhar músicas")
        self.currentActivity?.becomeCurrent()
    }

}
