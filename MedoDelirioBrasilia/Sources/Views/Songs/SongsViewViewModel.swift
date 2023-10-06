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

    // Alerts
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    @Published var alertType: AlertType = .singleOption

    // Toast
    @Published var showToastView: Bool = false
    @Published var toastIcon: String = "checkmark"
    @Published var toastIconColor: Color = .green
    @Published var toastText: String = ""

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
                showServerSoundNotAvailableAlert(song)
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
                        self.displayToast(toastText: Shared.songSharedSuccessfullyMessage)
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

                        self.displayToast(toastText: Shared.songSharedSuccessfullyMessage)
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
                        self.displayToast(toastText: Shared.videoSharedSuccessfullyMessage)
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
                    
                    self.displayToast(toastText: Shared.videoSharedSuccessfullyMessage)
                }
                
                WallE.deleteAllVideoFilesFromDocumentsDir()
            }
            
            isShowingShareSheet = true
        }
    }
    
    func showVideoSavedSuccessfullyToast() {
        self.displayToast(toastText: ProcessInfo.processInfo.isiOSAppOnMac ? Shared.ShareAsVideo.videoSavedSucessfullyMac : Shared.ShareAsVideo.videoSavedSucessfully)
    }
    
    func donateActivity() {
        self.currentActivity = UserActivityWaiter.getDonatableActivity(withType: Shared.ActivityTypes.playAndShareSongs, andTitle: "Ouvir e compartilhar músicas")
        self.currentActivity?.becomeCurrent()
    }

    func redownloadServerContent(withId contentId: String) {
        Task {
            do {
                guard let fileUrl = URL(string: baseURL + "songs/\(contentId).mp3") else { return }
                try await SyncService.downloadFile(
                    at: fileUrl,
                    to: InternalFolderNames.downloadedSongs,
                    contentId: contentId
                )
                displayToast(
                    "checkmark",
                    .green,
                    toastText: "Conteúdo baixado com sucesso. Tente tocá-lo novamente."
                )
            } catch {
                displayToast(
                    "exclamationmark.triangle.fill",
                    .orange,
                    toastText: "Erro ao tentar baixar conteúdo novamente."
                )
            }
        }
    }

    // MARK: - Alerts

    func showSongUnavailableAlert() {
        TapticFeedback.error()
        alertType = .twoOptions
        alertTitle = Shared.Songs.songNotFoundAlertTitle
        alertMessage = Shared.Songs.songNotFoundAlertMessage
        showAlert = true
    }

    func showServerSoundNotAvailableAlert(_ song: Song) {
        selectedSong = song
        TapticFeedback.error()
        alertType = .twoOptionsOneRedownload
        alertTitle = Shared.contentNotFoundAlertTitle(song.title)
        alertMessage = Shared.serverContentNotAvailableRedownloadMessage
        showAlert = true
    }

    // MARK: - Toast

    func displayToast(
        _ toastIcon: String = "checkmark",
        _ toastIconColor: Color = .green,
        toastText: String,
        completion: (() -> Void)? = nil
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
            withAnimation {
                self.toastIcon = toastIcon
                self.toastIconColor = toastIconColor
                self.toastText = toastText
                self.showToastView = true
            }
            TapticFeedback.success()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                self.showToastView = false
                completion?()
            }
        }
    }
}
