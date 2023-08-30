//
//  FolderDetailViewViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import Combine
import SwiftUI

class FolderDetailViewViewModel: ObservableObject {

    @Published var sounds = [Sound]()
    
    @Published var soundSortOption: Int = FolderSoundSortOption.titleAscending.rawValue
    
    @Published var hasSoundsToDisplay: Bool = false
    @Published var selectedSound: Sound? = nil
    @Published var selectedSounds: [Sound]? = nil
    @Published var nowPlayingKeeper = Set<String>()
    @Published var selectionKeeper = Set<String>()
    var currentSoundsListMode: Binding<SoundsListMode>
    
    // Playlist
    @Published var isPlayingPlaylist: Bool = false
    private var currentTrackIndex: Int = 0
    
    // Sharing
    @Published var iPadShareSheet = ActivityViewController(activityItems: [URL(string: "https://www.apple.com")!])
    @Published var isShowingShareSheet: Bool = false
    @Published var shareBannerMessage: String = .empty
    @Published var displaySharedSuccessfullyToast: Bool = false
    
    // Alerts
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    @Published var alertType: FolderDetailAlertType = .ok
    
    init(currentSoundsListMode: Binding<SoundsListMode>) {
        self.currentSoundsListMode = currentSoundsListMode
    }
    
    func reloadSoundList(
        withFolderContents folderContents: [UserFolderContent]?,
        sortedBy sortOption: FolderSoundSortOption
    ) {
        guard let folderContents = folderContents else {
            self.sounds = [Sound]()
            self.hasSoundsToDisplay = false
            return
        }
        
        let contentIds = folderContents.map { $0.contentId }
        guard let sounds = try? LocalDatabase.shared.sounds(withIds: contentIds) else { return }
        
        guard sounds.count > 0 else {
            self.sounds = [Sound]()
            self.hasSoundsToDisplay = false
            return
        }
        
        self.sounds = sounds
        
        for i in stride(from: 0, to: self.sounds.count, by: 1) {
            // DateAdded here is date added to folder not to the app as it means outside folders.
            self.sounds[i].dateAdded = folderContents.first(where: { $0.contentId == self.sounds[i].id })?.dateAdded
        }
        
        if sortOption.rawValue == self.soundSortOption {
            switch sortOption {
            case .titleAscending:
                sortSoundsInPlaceByTitleAscending()
            case .authorNameAscending:
                sortSoundsInPlaceByAuthorNameAscending()
            case .dateAddedDescending:
                sortSoundsInPlaceByDateAddedDescending()
            }
        } else {
            self.soundSortOption = sortOption.rawValue
        }
        
        self.hasSoundsToDisplay = true
    }
    
    func sortSoundsInPlaceByTitleAscending() {
        self.sounds.sort(by: { $0.title.withoutDiacritics() < $1.title.withoutDiacritics() })
    }
    
    func sortSoundsInPlaceByAuthorNameAscending() {
        self.sounds.sort(by: { $0.authorName?.withoutDiacritics() ?? "" < $1.authorName?.withoutDiacritics() ?? "" })
    }
    
    func sortSoundsInPlaceByDateAddedDescending() {
        self.sounds.sort(by: { $0.dateAdded ?? Date() > $1.dateAdded ?? Date() })
    }
    
    func getSoundCount() -> String {
        if sounds.count == 1 {
            return "1 SOM"
        } else {
            return "\(sounds.count) SONS"
        }
    }
    
    func playSound(fromPath filepath: String, withId soundId: String) {
        guard filepath.isEmpty == false else {
            return
        }
        
        guard let path = Bundle.main.path(forResource: filepath, ofType: nil) else {
            return showUnableToGetSoundAlert()
        }
        let url = URL(fileURLWithPath: path)
        
        nowPlayingKeeper.removeAll()
        nowPlayingKeeper.insert(soundId)

        AudioPlayer.shared = AudioPlayer(url: url, update: { [weak self] state in
            guard let self = self else { return }
            if state?.activity == .stopped {
                self.nowPlayingKeeper.removeAll()
                
                if self.isPlayingPlaylist {
                    self.currentTrackIndex += 1
                    
                    if self.currentTrackIndex >= self.sounds.count {
                        self.doPlaylistCleanup()
                        return
                    }
                    
                    self.playSound(fromPath: self.sounds[self.currentTrackIndex].filename, withId: self.sounds[self.currentTrackIndex].id)
                }
            }
        })
        
        AudioPlayer.shared?.togglePlay()
    }
    
    func stopPlaying() {
        if nowPlayingKeeper.count > 0 {
            AudioPlayer.shared?.togglePlay()
            nowPlayingKeeper.removeAll()
            doPlaylistCleanup()
        }
    }
    
    func share(sound: Sound) {
        if UIDevice.current.userInterfaceIdiom == .phone {
            do {
                try SharingUtility.shareSound(from: sound.fileURL(), andContentId: sound.id) { didShareSuccessfully in
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
            do {
                let url = try sound.fileURL()

                iPadShareSheet = ActivityViewController(activityItems: [url]) { activity, completed, items, error in
                    if completed {
                        guard let activity = activity else {
                            return
                        }
                        let destination = ShareDestination.translateFrom(activityTypeRawValue: activity.rawValue)
                        Logger.shared.logSharedSound(contentId: sound.id, destination: destination, destinationBundleId: activity.rawValue)

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
            } catch {
                showUnableToGetSoundAlert()
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
    
    func removeSoundFromFolder(folderId: String, soundId: String) {
        try? LocalDatabase.shared.deleteUserContentFromFolder(withId: folderId, contentId: soundId)
        reloadSoundList(withFolderContents: try? LocalDatabase.shared.getAllContentsInsideUserFolder(withId: folderId), sortedBy: FolderSoundSortOption(rawValue: soundSortOption) ?? .titleAscending)
    }
    
    // MARK: - Multi-Select
    
    func startSelecting() {
        stopPlaying()
        if currentSoundsListMode.wrappedValue == .regular {
            currentSoundsListMode.wrappedValue = .selection
        } else {
            currentSoundsListMode.wrappedValue = .regular
            selectionKeeper.removeAll()
        }
    }
    
    func stopSelecting() {
        currentSoundsListMode.wrappedValue = .regular
        selectionKeeper.removeAll()
    }
    
    func removeMultipleSoundsFromFolder(folderId: String) {
        guard selectionKeeper.count > 0 else { return }
        selectionKeeper.forEach { selectedSoundId in
            try? LocalDatabase.shared.deleteUserContentFromFolder(withId: folderId, contentId: selectedSoundId)
        }
        selectionKeeper.removeAll()
        reloadSoundList(withFolderContents: try? LocalDatabase.shared.getAllContentsInsideUserFolder(withId: folderId), sortedBy: FolderSoundSortOption(rawValue: soundSortOption) ?? .titleAscending)
    }
    
    func sendUsageMetricToServer(action: String, folderName: String) {
        let usageMetric = UsageMetric(customInstallId: UIDevice.customInstallId,
                                      originatingScreen: "FolderDetailView(\(folderName))",
                                      destinationScreen: action,
                                      systemName: UIDevice.current.systemName,
                                      isiOSAppOnMac: ProcessInfo.processInfo.isiOSAppOnMac,
                                      appVersion: Versioneer.appVersion,
                                      dateTime: Date.now.iso8601withFractionalSeconds,
                                      currentTimeZone: TimeZone.current.abbreviation() ?? .empty)
        networkRabbit.post(usageMetric: usageMetric)
    }
    
    // MARK: - Playlist
    
    func playAllSoundsOneAfterTheOther() {
        guard let firstSound = sounds.first else { return }
        isPlayingPlaylist = true
        playSound(fromPath: firstSound.filename, withId: firstSound.id)
    }
    
    func playFrom(sound: Sound) {
        guard let soundIndex = sounds.firstIndex(where: { $0.id == sound.id }) else { return }
        let soundInArray = sounds[soundIndex]
        currentTrackIndex = soundIndex
        isPlayingPlaylist = true
        playSound(fromPath: soundInArray.filename, withId: soundInArray.id)
    }
    
    func doPlaylistCleanup() {
        currentTrackIndex = 0
        isPlayingPlaylist = false
    }
    
    // MARK: - Alerts
    
    func showUnableToGetSoundAlert() {
        TapticFeedback.error()
        alertTitle = Shared.soundNotFoundAlertTitle
        alertMessage = Shared.soundNotFoundAlertMessage
        alertType = .ok
        showAlert = true
    }
    
    func showSoundRemovalConfirmation(soundTitle: String) {
        alertTitle = "Remover \"\(soundTitle)\"?"
        alertMessage = "O som continuará disponível fora da pasta."
        alertType = .removeSingleSound
        showAlert = true
    }
    
    func showRemoveMultipleSoundsConfirmation() {
        alertTitle = "Remover os sons selecionados?"
        alertMessage = "Os sons continuarão disponíveis fora da pasta."
        alertType = .removeMultipleSounds
        showAlert = true
    }

}
