//
//  SoundsViewViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 19/05/22.
//

import Combine
import SwiftUI

class SoundsViewViewModel: ObservableObject {

    @Published var sounds: [Sound] = []
    
    @Published var soundSortOption: Int
    @Published var authorSortOption: Int
    
    @Published var favoritesKeeper = Set<String>()
    @Published var highlightKeeper = Set<String>()
    @Published var nowPlayingKeeper = Set<String>()
    @Published var selectionKeeper = Set<String>()
    @Published var showEmailAppPicker_suggestOtherAuthorNameConfirmationDialog = false
    @Published var showEmailAppPicker_soundUnavailableConfirmationDialog = false
    @Published var showEmailAppPicker_sendFeedback = false
    @Published var selectedSound: Sound? = nil
    @Published var selectedSounds: [Sound]? = nil
    var currentSoundsListMode: Binding<SoundsListMode>
    
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

    init(soundSortOption: Int, authorSortOption: Int, currentSoundsListMode: Binding<SoundsListMode>) {
        self.soundSortOption = soundSortOption
        self.authorSortOption = authorSortOption
        self.currentSoundsListMode = currentSoundsListMode
    }

    func reloadList(currentMode: SoundsView.ViewMode) {
        guard currentMode == .allSounds || currentMode == .favorites else { return }

        do {
            sounds = try LocalDatabase.shared.sounds(
                allowSensitive: UserSettings.getShowExplicitContent(),
                favoritesOnly: currentMode == .favorites
            )

            guard sounds.count > 0 else { return }

            favoritesKeeper.removeAll()
            let favorites = try LocalDatabase.shared.favorites()
            if favorites.count > 0 {
                for favorite in favorites {
                    favoritesKeeper.insert(favorite.contentId)
                }
            }

            let sortOption: SoundSortOption = SoundSortOption(rawValue: UserSettings.getSoundSortOption()) ?? .dateAddedDescending
            sortSounds(by: sortOption)
        } catch {
            print("Erro")
        }
    }

    func sortSounds(by sortOption: SoundSortOption) {
        switch sortOption {
        case .titleAscending:
            sortSoundsInPlaceByTitleAscending()
        case .authorNameAscending:
            sortSoundsInPlaceByAuthorNameAscending()
        case .dateAddedDescending:
            sortSoundsInPlaceByDateAddedDescending()
        case .shortestFirst:
            sortSoundsInPlaceByDurationAscending()
        case .longestFirst:
            sortSoundsInPlaceByDurationDescending()
        case .longestTitleFirst:
            sortSoundsInPlaceByTitleLengthDescending()
        case .shortestTitleFirst:
            sortSoundsInPlaceByTitleLengthAscending()
        }
    }

    private func sortSoundsInPlaceByTitleAscending() {
        sounds.sort(by: { $0.title.withoutDiacritics() < $1.title.withoutDiacritics() })
    }

    private func sortSoundsInPlaceByAuthorNameAscending() {
        sounds.sort(by: { $0.authorName?.withoutDiacritics() ?? "" < $1.authorName?.withoutDiacritics() ?? "" })
    }

    private func sortSoundsInPlaceByDateAddedDescending() {
        sounds.sort(by: { $0.dateAdded ?? Date() > $1.dateAdded ?? Date() })
    }

    private func sortSoundsInPlaceByDurationAscending() {
        sounds.sort(by: { $0.duration < $1.duration })
    }

    private func sortSoundsInPlaceByDurationDescending() {
        sounds.sort(by: { $0.duration > $1.duration })
    }

    private func sortSoundsInPlaceByTitleLengthAscending() {
        sounds.sort(by: { $0.title.count < $1.title.count })
    }

    private func sortSoundsInPlaceByTitleLengthDescending() {
        sounds.sort(by: { $0.title.count > $1.title.count })
    }

    func play(_ sound: Sound) {
        do {
            let url = try sound.fileURL()
            
            nowPlayingKeeper.removeAll()
            nowPlayingKeeper.insert(sound.id)
            
            AudioPlayer.shared = AudioPlayer(url: url, update: { [weak self] state in
                guard let self = self else { return }
                if state?.activity == .stopped {
                    self.nowPlayingKeeper.removeAll()
                }
            })
            
            AudioPlayer.shared?.togglePlay()
        } catch {
            if sound.isFromServer ?? false {
                showServerSoundNotAvailableAlert()
            } else {
                showUnableToGetSoundAlert()
            }
        }
    }
    
    func stopPlaying() {
        if nowPlayingKeeper.count > 0 {
            AudioPlayer.shared?.togglePlay()
            nowPlayingKeeper.removeAll()
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
                        self.isShowingShareSheet = false

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
    
    func addToFavorites(soundId: String) {
        let newFavorite = Favorite(contentId: soundId, dateAdded: Date())
        
        do {
            let favorteAlreadyExists = try LocalDatabase.shared.exists(contentId: soundId)
            guard favorteAlreadyExists == false else { return }
            
            try LocalDatabase.shared.insert(favorite: newFavorite)
            favoritesKeeper.insert(newFavorite.contentId)
        } catch {
            print("Problem saving favorite \(newFavorite.contentId): \(error.localizedDescription)")
        }
    }
    
    func removeFromFavorites(soundId: String) {
        do {
            try LocalDatabase.shared.deleteFavorite(withId: soundId)
            favoritesKeeper.remove(soundId)
        } catch {
            print("Problem removing favorite \(soundId)")
        }
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
            guard let sound = try? LocalDatabase.shared.sound(withId: selectedSoundId) else { return }
            selectedSounds?.append(sound)
        }
    }
    
    func shareSelected() {
        guard selectionKeeper.count > 0 else { return }
        selectedSounds = [Sound]()
        selectionKeeper.forEach { selectedSoundId in
            guard let sound = try? LocalDatabase.shared.sound(withId: selectedSoundId) else { return }
            selectedSounds?.append(sound)
        }
        
        do {
            try SharingUtility.share(sounds: selectedSounds ?? [Sound]()) { didShareSuccessfully in
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
    
    // MARK: - Other
    
    func donateActivity() {
        self.currentActivity = UserActivityWaiter.getDonatableActivity(withType: Shared.ActivityTypes.playAndShareSounds, andTitle: "Ouvir e compartilhar sons")
        self.currentActivity?.becomeCurrent()
    }
    
    func sendUserPersonalTrendsToServerIfEnabled() {
        guard UserSettings.getEnableTrends() else {
            return
        }
        guard UserSettings.getEnableShareUserPersonalTrends() else {
            return
        }
        
        if let lastDate = AppPersistentMemory.getLastSendDateOfUserPersonalTrendsToServer() {
            if lastDate.onlyDate! < Date.now.onlyDate! {
                podium.sendShareCountStatsToServer { result, _ in
                    guard result == .successful || result == .noStatsToSend else {
                        return
                    }
                    AppPersistentMemory.setLastSendDateOfUserPersonalTrendsToServer(to: Date.now.onlyDate!)
                }
            }
        } else {
            podium.sendShareCountStatsToServer { result, _ in
                guard result == .successful || result == .noStatsToSend else {
                    return
                }
                AppPersistentMemory.setLastSendDateOfUserPersonalTrendsToServer(to: Date.now.onlyDate!)
            }
        }
    }
    
    // MARK: - Alerts
    
    func showUnableToGetSoundAlert() {
        TapticFeedback.error()
        alertType = .twoOptions
        alertTitle = Shared.soundNotFoundAlertTitle
        alertMessage = Shared.soundNotFoundAlertMessage
        showAlert = true
    }
    
    func showServerSoundNotAvailableAlert() {
        TapticFeedback.error()
        alertType = .twoOptions
        alertTitle = Shared.soundNotFoundAlertTitle
        alertMessage = Shared.serverSoundNotAvailableMessage
        showAlert = true
    }
    
    func showMoveDatabaseIssueAlert() {
        TapticFeedback.error()
        alertType = .singleOption
        alertTitle = "Problema ao Mover o Banco de Dados"
        alertMessage = "Houve um problema ao tentar mover o banco de dados do app. Por favor, envie um print desse erro para o desenvolvedor (e-mail nas Configurações):\n\n\(moveDatabaseIssue)"
        showAlert = true
    }
}
