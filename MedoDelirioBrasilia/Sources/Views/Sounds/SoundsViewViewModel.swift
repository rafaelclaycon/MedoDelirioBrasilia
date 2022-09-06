import Combine
import SwiftUI

class SoundsViewViewModel: ObservableObject {

    @Published var sounds = [Sound]()
    
    @Published var sortOption: Int
    @Published var favoritesKeeper = Set<String>()
    @Published var showEmailAppPicker_suggestOtherAuthorNameConfirmationDialog = false
    @Published var showEmailAppPicker_soundUnavailableConfirmationDialog = false
    @Published var selectedSound: Sound? = nil
    
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
    
    init(sortOption: Int) {
        self.sortOption = sortOption
    }
    
    func reloadList(withSounds allSounds: [Sound],
                    andFavorites favorites: [Favorite]?,
                    allowSensitiveContent: Bool,
                    favoritesOnly: Bool,
                    sortedBy sortOption: SoundSortOption) {
        var soundsCopy = allSounds
        
        if favoritesOnly, let favorites = favorites {
            soundsCopy = soundsCopy.filter({ sound in
                favorites.contains(where: { $0.contentId == sound.id })
            })
        }
        
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
            
            switch sortOption {
            case .titleAscending:
                sortSoundsInPlaceByTitleAscending()
            case .authorNameAscending:
                sortSoundsInPlaceByAuthorNameAscending()
            case .dateAddedDescending:
                sortSoundsInPlaceByDateAddedDescending()
            }
        }
    }
    
    private func sortSoundsInPlaceByTitleAscending() {
        self.sounds.sort(by: { $0.title.withoutDiacritics() < $1.title.withoutDiacritics() })
    }
    
    private func sortSoundsInPlaceByAuthorNameAscending() {
        self.sounds.sort(by: { $0.authorName?.withoutDiacritics() ?? "" < $1.authorName?.withoutDiacritics() ?? "" })
    }
    
    private func sortSoundsInPlaceByDateAddedDescending() {
        self.sounds.sort(by: { $0.dateAdded ?? Date() > $1.dateAdded ?? Date() })
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
                    self.isShowingShareSheet = false
                    
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
            }
            
            isShowingShareSheet = true
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
    
    // MARK: - Other
    
    func donateActivity() {
        self.currentActivity = UserActivityWaiter.getDonatableActivity(withType: Shared.ActivityTypes.playAndShareSounds, andTitle: "Tocar e compartilhar sons")
        self.currentActivity?.becomeCurrent()
    }
    
    func sendDeviceModelNameToServer() {
        if AppPersistentMemory.getHasSentDeviceModelToServer() == false {
            guard UIDevice.modelName.contains("Simulator") == false else {
                return
            }
            guard CommandLine.arguments.contains("-UNDER_DEVELOPMENT") == false else {
                return
            }
            
            let info = ClientDeviceInfo(installId: UIDevice.identifiderForVendor, modelName: UIDevice.modelName)
            networkRabbit.post(clientDeviceInfo: info) { success, error in
                if let success = success, success {
                    AppPersistentMemory.setHasSentDeviceModelToServer(to: true)
                }
            }
        }
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
                podium.exchangeShareCountStatsWithTheServer { result, _ in
                    guard result == .successful || result == .noStatsToSend else {
                        return
                    }
                    AppPersistentMemory.setLastSendDateOfUserPersonalTrendsToServer(to: Date.now.onlyDate!)
                }
            }
        } else {
            podium.exchangeShareCountStatsWithTheServer { result, _ in
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
    
    func showNoFoldersAlert() {
        TapticFeedback.error()
        alertType = .singleOption
        alertTitle = "Não Existem Pastas"
        alertMessage = "Para continuar, crie uma pasta de sons na aba Coleções > Minhas Pastas."
        showAlert = true
    }

}
