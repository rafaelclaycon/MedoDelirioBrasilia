//
//  SongsViewViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 19/05/22.
//

import Foundation
import SwiftUI

@Observable class SongsViewViewModel {

    var songs = [Song]()

    var sortOption: Int = 0

    var nowPlayingKeeper = Set<String>()
    var highlightKeeper = Set<String>()

    var showEmailAppPicker_suggestChangeConfirmationDialog = false
    var showEmailAppPicker_songUnavailableConfirmationDialog = false
    var selectedSong: Song? = nil

    var searchText = ""

    var currentActivity: NSUserActivity? = nil

    // Sharing
    var iPadShareSheet = ActivityViewController(activityItems: [URL(string: "https://www.apple.com")!])
    var isShowingShareSheet: Bool = false
    var shareBannerMessage: String = ""
    var songToShareAsVideo: Song?

    // Redownload Content
    var isShowingProcessingView: Bool = false

    // Alerts
    var alertTitle: String = ""
    var alertMessage: String = ""
    var showAlert: Bool = false
    var alertType: SongsViewAlert = .ok

    // Toast
    var toast: Toast?

    // MARK: - Stored Properties

    private var database: LocalDatabaseProtocol
    private var logger: LoggerProtocol

    // MARK: - Initializer

    init(
        database: LocalDatabaseProtocol,
        logger: LoggerProtocol
    ) {
        self.database = database
        self.logger = logger
    }
}

// MARK: - Functions

extension SongsViewViewModel {

    func reloadList() {
        do {
            songs = try database.songs(allowSensitive: UserSettings().getShowExplicitContent())

            guard songs.count > 0 else { return }

            let sortOption: SongSortOption = SongSortOption(rawValue: UserSettings().getSongSortOption()) ?? .dateAddedDescending
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
                showServerSongNotAvailableAlert(song)
            } else {
                showSongUnavailableAlert()
            }
        }
    }

    func share(song: Song) {
        if UIDevice.isiPhone {
            do {
                try SharingUtility.shareSound(
                    from: song.fileURL(),
                    andContentId: song.id,
                    context: .song
                ) { didShareSuccessfully in
                    if didShareSuccessfully {
                        self.toast = Toast(message: Shared.songSharedSuccessfullyMessage, type: .success)
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
                        self.logger.logShared(.song, contentId: song.id, destination: destination, destinationBundleId: activity.rawValue)

                        AppStoreReviewSteward.requestReviewBasedOnVersionAndCount()

                        self.toast = Toast(message: Shared.songSharedSuccessfullyMessage, type: .success)
                    }
                }
            } catch {
                showSongUnavailableAlert()
            }

            isShowingShareSheet = true
        }
    }
    
    func shareVideo(withPath filepath: String, andContentId contentId: String) {
        if UIDevice.isiPhone {
            do {
                try SharingUtility.share(
                    .videoFromSong,
                    withPath: filepath,
                    andContentId: contentId,
                    shareSheetDelayInSeconds: 0.6
                ) { didShareSuccessfully in
                    if didShareSuccessfully {
                        self.toast = Toast(message: Shared.videoSharedSuccessfullyMessage, type: .success)
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
                    self.logger.logShared(.videoFromSong, contentId: contentId, destination: destination, destinationBundleId: activity.rawValue)

                    AppStoreReviewSteward.requestReviewBasedOnVersionAndCount()
                    
                    self.toast = Toast(message: Shared.videoSharedSuccessfullyMessage, type: .success)
                }
                
                WallE.deleteAllVideoFilesFromDocumentsDir()
            }
            
            isShowingShareSheet = true
        }
    }
    
    func showVideoSavedSuccessfullyToast() {
        toast = Toast(
            message: UIDevice.isMac ? Shared.ShareAsVideo.videoSavedSucessfullyMac : Shared.ShareAsVideo.videoSavedSucessfully,
            type: .success
        )
    }
    
    func donateActivity() {
        self.currentActivity = UserActivityWaiter.getDonatableActivity(withType: Shared.ActivityTypes.playAndShareSongs, andTitle: "Ouvir e compartilhar músicas")
        self.currentActivity?.becomeCurrent()
    }

    func redownloadServerContent(withId contentId: String) {
        Task {
            do {
                guard let fileUrl = URL(string: APIConfig.baseServerURL + "songs/\(contentId).mp3") else { return }
                isShowingProcessingView = true
                try await ContentUpdateService.downloadFile(
                    at: fileUrl,
                    to: InternalFolderNames.downloadedSongs,
                    contentId: contentId
                )
                isShowingProcessingView = false
                toast = Toast(message: "Conteúdo baixado com sucesso. Tente tocá-lo novamente.", type: .success)
            } catch {
                isShowingProcessingView = false
                toast = Toast(message: "Erro ao tentar baixar conteúdo novamente.", type: .warning)
            }
        }
    }

    func cancelSearchAndHighlight(id songId: String) {
        if !searchText.isEmpty {
            searchText = ""
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }

        highlightKeeper.insert(songId)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            self.highlightKeeper.remove(songId)
        }
    }

    // MARK: - Alerts

    func showSongUnavailableAlert() {
        HapticFeedback.error()
        alertType = .songUnavailable
        alertTitle = Shared.Songs.songNotFoundAlertTitle
        alertMessage = Shared.Songs.songNotFoundAlertMessage
        showAlert = true
    }

    func showServerSongNotAvailableAlert(_ song: Song) {
        selectedSong = song
        HapticFeedback.error()
        alertType = .redownloadSong
        alertTitle = Shared.contentNotFoundAlertTitle(song.title)
        alertMessage = Shared.serverContentNotAvailableRedownloadMessage
        showAlert = true
    }
}
