//
//  AuthorsDetailViewViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 19/05/22.
//

import Combine
import SwiftUI

class AuthorDetailViewViewModel: ObservableObject {

    @Published var sounds = [Sound]()
    
    @Published var soundSortOption: Int = 1
    @Published var favoritesKeeper = Set<String>()
    @Published var nowPlayingKeeper = Set<String>()
    @Published var selectionKeeper = Set<String>()
    @Published var selectedSound: Sound? = nil
    @Published var selectedSounds: [Sound]? = nil
    
    @Published var showEmailAppPicker_suggestOtherAuthorNameConfirmationDialog = false
    @Published var showEmailAppPicker_soundUnavailableConfirmationDialog = false
    @Published var showEmailAppPicker_askForNewSound = false
    @Published var showEmailAppPicker_reportAuthorDetailIssue = false
    var currentSoundsListMode: Binding<SoundsListMode>
    
    // Sharing
    @Published var iPadShareSheet = ActivityViewController(activityItems: [URL(string: "https://www.apple.com")!])
    @Published var isShowingShareSheet: Bool = false
    @Published var shareBannerMessage: String = .empty
    @Published var displaySharedSuccessfullyToast: Bool = false
    
    // Alerts
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    @Published var alertType: AuthorDetailAlertType = .ok
    
    init(originatingScreenName: String, authorName: String, currentSoundsListMode: Binding<SoundsListMode>) {
        self.currentSoundsListMode = currentSoundsListMode
        // Sends metric only from iPhones because iPad and Mac are calling this methods twice instead of once upon each screen opening.
        if UIDevice.current.userInterfaceIdiom == .phone {
            sendUsageMetricToServer(originatingScreenName: originatingScreenName, authorName: authorName)
        }
    }
    
    func reloadList(withSounds allSounds: [Sound],
                    andFavorites favorites: [Favorite]?,
                    allowSensitiveContent: Bool) {
        var soundsCopy = allSounds
        
        if allowSensitiveContent == false {
            soundsCopy = soundsCopy.filter({ $0.isOffensive == false })
        }
        
        self.sounds = soundsCopy
        
        // From here the sounds array is already set
        if self.sounds.count > 0 {
            // Needed because author names live in a different file.
            for i in 0...(self.sounds.count - 1) {
                self.sounds[i].authorName = authorData.first(where: { $0.id == self.sounds[i].authorId })?.name ?? Shared.unknownAuthor
            }
            
            // Populate Favorites Keeper to display favorite cells accordingly
            if let favorites = favorites, favorites.count > 0 {
                for favorite in favorites {
                    favoritesKeeper.insert(favorite.contentId)
                }
            } else {
                favoritesKeeper.removeAll()
            }

            sortSoundsInPlaceByDateAddedDescending()
        }
    }
    
    func sortSoundsInPlaceByTitleAscending() {
        self.sounds.sort(by: { $0.title.withoutDiacritics() < $1.title.withoutDiacritics() })
    }
    
    func sortSoundsInPlaceByDateAddedDescending() {
        self.sounds.sort(by: { $0.dateAdded ?? Date() > $1.dateAdded ?? Date() })
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

        player = AudioPlayer(url: url, update: { [weak self] state in
            guard let self = self else { return }
            if state?.activity == .stopped {
                self.nowPlayingKeeper.removeAll()
            }
        })
        
        player?.togglePlay()
    }
    
    func stopPlaying() {
        if nowPlayingKeeper.count > 0 {
            player?.togglePlay()
            nowPlayingKeeper.removeAll()
        }
    }
    
    func shareSound(withPath filepath: String, andContentId contentId: String) {
        if UIDevice.current.userInterfaceIdiom == .phone {
            do {
                try Sharer.shareSound(withPath: filepath, andContentId: contentId) { didShareSuccessfully in
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
            guard filepath.isEmpty == false else {
                return
            }
            
            guard let path = Bundle.main.path(forResource: filepath, ofType: nil) else {
                return showUnableToGetSoundAlert()
            }
            let url = URL(fileURLWithPath: path)
            
            iPadShareSheet = ActivityViewController(activityItems: [url]) { activity, completed, items, error in
                if completed {
                    guard let activity = activity else {
                        return
                    }
                    let destination = ShareDestination.translateFrom(activityTypeRawValue: activity.rawValue)
                    Logger.logSharedSound(contentId: contentId, destination: destination, destinationBundleId: activity.rawValue)
                    
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
                    Logger.logSharedVideoFromSound(contentId: contentId, destination: destination, destinationBundleId: activity.rawValue)
                    
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
    
    func addToFavorites(soundId: String) {
        let newFavorite = Favorite(contentId: soundId, dateAdded: Date())
        
        do {
            try database.insert(favorite: newFavorite)
            favoritesKeeper.insert(newFavorite.contentId)
        } catch {
            print("Problem saving favorite \(newFavorite.contentId)")
        }
    }
    
    func removeFromFavorites(soundId: String) {
        do {
            try database.deleteFavorite(withId: soundId)
            favoritesKeeper.remove(soundId)
        } catch {
            print("Problem removing favorite \(soundId)")
        }
    }
    
    func getSoundCount() -> String {
        if sounds.count == 1 {
            return "1 SOM"
        } else {
            return "\(sounds.count) SONS"
        }
    }
    
    private func sendUsageMetricToServer(originatingScreenName: String, authorName: String) {
        let usageMetric = UsageMetric(customInstallId: UIDevice.customInstallId,
                                      originatingScreen: originatingScreenName,
                                      destinationScreen: "\(Shared.ScreenNames.authorDetailView)(\(authorName))",
                                      systemName: UIDevice.current.systemName,
                                      isiOSAppOnMac: ProcessInfo.processInfo.isiOSAppOnMac,
                                      appVersion: Versioneer.appVersion,
                                      dateTime: Date.now.iso8601withFractionalSeconds,
                                      currentTimeZone: TimeZone.current.abbreviation() ?? .empty)
        networkRabbit.post(usageMetric: usageMetric)
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
    
    func addSelectedToFavorites() {
        guard selectionKeeper.count > 0 else { return }
        selectionKeeper.forEach { selectedSound in
            addToFavorites(soundId: selectedSound)
        }
    }
    
    func removeSelectedFromFavorites() {
        guard selectionKeeper.count > 0 else { return }
        selectionKeeper.forEach { selectedSound in
            removeFromFavorites(soundId: selectedSound)
        }
    }
    
    func allSelectedAreFavorites() -> Bool {
        guard selectionKeeper.count > 0 else { return false }
        return selectionKeeper.isSubset(of: favoritesKeeper)
    }
    
    func prepareSelectedToAddToFolder() {
        guard selectionKeeper.count > 0 else { return }
        selectedSounds = [Sound]()
        selectionKeeper.forEach { selectedSoundId in
            guard let sound = soundData.filter({ $0.id == selectedSoundId }).first else { return }
            selectedSounds?.append(sound)
        }
    }
    
    func shareSelected() {
        guard selectionKeeper.count > 0 else { return }
        selectedSounds = [Sound]()
        selectionKeeper.forEach { selectedSoundId in
            guard let sound = soundData.filter({ $0.id == selectedSoundId }).first else { return }
            selectedSounds?.append(sound)
        }
        
        do {
            try Sharer.share(sounds: selectedSounds ?? [Sound]()) { didShareSuccessfully in
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
    }
    
    func sendUsageMetricToServer(action: String) {
        let usageMetric = UsageMetric(customInstallId: UIDevice.customInstallId,
                                      originatingScreen: "SoundsView",
                                      destinationScreen: action,
                                      systemName: UIDevice.current.systemName,
                                      isiOSAppOnMac: ProcessInfo.processInfo.isiOSAppOnMac,
                                      appVersion: Versioneer.appVersion,
                                      dateTime: Date.now.iso8601withFractionalSeconds,
                                      currentTimeZone: TimeZone.current.abbreviation() ?? .empty)
        networkRabbit.post(usageMetric: usageMetric)
    }
    
    // MARK: - Alerts
    
    func showUnableToGetSoundAlert() {
        TapticFeedback.error()
        alertType = .reportSoundIssue
        alertTitle = Shared.soundNotFoundAlertTitle
        alertMessage = Shared.soundNotFoundAlertMessage
        showAlert = true
    }
    
    func showAskForNewSoundAlert() {
        TapticFeedback.warning()
        alertType = .askForNewSound
        alertTitle = Shared.AuthorDetail.AskForNewSoundAlert.title
        alertMessage = Shared.AuthorDetail.AskForNewSoundAlert.message
        showAlert = true
    }

}
