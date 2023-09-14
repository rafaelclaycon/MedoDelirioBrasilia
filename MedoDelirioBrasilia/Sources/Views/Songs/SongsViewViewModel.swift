//
//  SongsViewViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 19/05/22.
//

import Foundation
import Combine
import SwiftUI

class SongsViewViewModel: ObservableObject {

    @Published var songs = [Song]()
    
    @Published var sortOption: Int = 0
    @Published var nowPlayingKeeper = Set<String>()
    @Published var showEmailAppPicker_suggestChangeConfirmationDialog = false
    @Published var showEmailAppPicker_songUnavailableConfirmationDialog = false
    @Published var selectedSong: Song? = nil
    
    @Published var currentActivity: NSUserActivity? = nil
    
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
    
    func reloadList() {
        do {
            songs = try LocalDatabase.shared.songs(
                allowSensitive: UserSettings.getShowExplicitContent()
            )

            guard songs.count > 0 else { return }

            let sortOption: SongSortOption = SongSortOption(rawValue: UserSettings.getSongSortOption()) ?? .dateAddedDescending
            sortSongs(by: sortOption)
        } catch {
            print("Erro")
        }
    }

    func sortSongs(by sortOption: SongSortOption) {
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
    
    func play(song: Song) {
        do {
            let url = try song.fileURL()

            nowPlayingKeeper.removeAll()
            nowPlayingKeeper.insert(song.id)

            AudioPlayer.shared = AudioPlayer(url: url, update: { [weak self] state in
                if state?.activity == .stopped {
                    self?.nowPlayingKeeper.removeAll()
                }
            })

            AudioPlayer.shared?.togglePlay()
        } catch {
            if song.isFromServer ?? false {
                showServerSongNotAvailableAlert()
            } else {
                showSongUnavailableAlert()
            }
        }
    }

    func share(song: Song) {
        if UIDevice.current.userInterfaceIdiom == .phone {
            do {
                try SharingUtility.shareSound(from: song.fileURL(), andContentId: song.id) { didShareSuccessfully in
                    if didShareSuccessfully {
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
                            withAnimation {
                                self.shareBannerMessage = Shared.songSharedSuccessfullyMessage
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
                showSongUnavailableAlert()
            }
        } else {
            do {
                let url = try song.fileURL()

                iPadShareSheet = ActivityViewController(activityItems: [url]) { activity, completed, items, error in
                    if completed {
                        self.isShowingShareSheet = false

                        guard let activity = activity else {
                            return
                        }
                        let destination = ShareDestination.translateFrom(activityTypeRawValue: activity.rawValue)
                        Logger.shared.logSharedSound(contentId: song.id, destination: destination, destinationBundleId: activity.rawValue)

                        AppStoreReviewSteward.requestReviewBasedOnVersionAndCount()

                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
                            withAnimation {
                                self.shareBannerMessage = Shared.songSharedSuccessfullyMessage
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
                showSongUnavailableAlert()
            }

            isShowingShareSheet = true
        }
    }
    
    func shareVideo(withPath filepath: String, andContentId contentId: String) {
        if UIDevice.current.userInterfaceIdiom == .phone {
            do {
                try SharingUtility.shareVideoFromSound(withPath: filepath, andContentId: contentId, shareSheetDelayInSeconds: 0.6) { didShareSuccessfully in
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
            
            iPadShareSheet = ActivityViewController(activityItems: [url]) { activity, completed, items, error in
                if completed {
                    self.isShowingShareSheet = false
                    
                    guard let activity = activity else {
                        return
                    }
                    let destination = ShareDestination.translateFrom(activityTypeRawValue: activity.rawValue)
                    Logger.shared.logSharedVideoFromSound(contentId: contentId, destination: destination, destinationBundleId: activity.rawValue)
                    
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
                
                WallE.deleteAllVideoFilesFromDocumentsDir()
            }
            
            isShowingShareSheet = true
        }
    }
    
    func showVideoSavedSuccessfullyToast() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
            withAnimation {
                self.shareBannerMessage = ProcessInfo.processInfo.isiOSAppOnMac ? Shared.ShareAsVideo.videoSavedSucessfullyMac : Shared.ShareAsVideo.videoSavedSucessfully
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
    
    func donateActivity() {
        self.currentActivity = UserActivityWaiter.getDonatableActivity(withType: Shared.ActivityTypes.playAndShareSongs, andTitle: "Ouvir e compartilhar músicas")
        self.currentActivity?.becomeCurrent()
    }
    
    // MARK: - Alerts
    
    func showSongUnavailableAlert() {
        TapticFeedback.error()
        alertType = .twoOptions
        alertTitle = Shared.Songs.songNotFoundAlertTitle
        alertMessage = Shared.Songs.songNotFoundAlertMessage
        showAlert = true
    }

    func showServerSongNotAvailableAlert() {
        TapticFeedback.error()
        alertType = .twoOptions
        alertTitle = Shared.Songs.songNotFoundAlertTitle
        alertMessage = Shared.serverContentNotAvailableMessage
        showAlert = true
    }
}
