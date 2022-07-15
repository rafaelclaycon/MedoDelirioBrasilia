import Combine
import SwiftUI
import StoreKit

class SoundsViewViewModel: ObservableObject {

    @Published var sounds = [Sound]()
    
    @Published var sortOption: Int = 0
    @Published var favoritesKeeper = Set<String>()
    @Published var showConfirmationDialog = false
    @Published var showEmailAppPicker_suggestOtherAuthorNameConfirmationDialog = false
    @Published var showEmailAppPicker_soundUnavailableConfirmationDialog = false
    @Published var soundForConfirmationDialog: Sound? = nil
    
    @Published var currentActivity: NSUserActivity? = nil
    
    // Sharing
    @Published var shouldDisplaySharedSuccessfullyToast: Bool = false
    
    // Alerts
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    @Published var alertType: AlertType = .singleOption
    
    func reloadList(withSounds allSounds: [Sound],
                    andFavorites favorites: [Favorite]?,
                    allowSensitiveContent: Bool,
                    favoritesOnly: Bool,
                    sortedBy sortOption: ContentSortOption) {
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
        self.sortOption = sortOption.rawValue
        
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
            showUnableToGetSoundAlert()
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
    
    func isSelectedSoundAlreadyAFavorite() -> Bool {
        guard let soundId = soundForConfirmationDialog?.id else {
            return false
        }
        return favoritesKeeper.contains(soundId)
    }
    
    func getFavoriteButtonTitle() -> String {
        let emoji = Shared.removeFromFavoritesEmojis.randomElement() ?? ""
        return isSelectedSoundAlreadyAFavorite() ? "\(emoji)  Remover dos Favoritos" : "⭐️  Adicionar aos Favoritos"
    }
    
    // MARK: - Other
    
    func donateActivity() {
        self.currentActivity = UserActivityWaiter.getDonatableActivity(withType: Shared.playAndShareSoundsActivityTypeName, andTitle: "Tocar e compartilhar sons")
        self.currentActivity?.becomeCurrent()
    }
    
    func sendDeviceModelNameToServer() {
        if UserSettings.getHasSentDeviceModelToServer() == false {
            guard UIDevice.modelName.contains("Simulator") == false else {
                return
            }
            guard CommandLine.arguments.contains("-UNDER_DEVELOPMENT") == false else {
                return
            }
            
            let info = ClientDeviceInfo(installId: UIDevice.current.identifierForVendor?.uuidString ?? "", modelName: UIDevice.modelName)
            networkRabbit.post(clientDeviceInfo: info) { success, error in
                if let success = success, success {
                    UserSettings.setHasSentDeviceModelToServer(to: true)
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
        
        if let lastDate = UserSettings.getLastSendDateOfUserPersonalTrendsToServer() {
            if lastDate.onlyDate! < Date.now.onlyDate! {
                podium.exchangeShareCountStatsWithTheServer { result, _ in
                    guard result == .successful || result == .noStatsToSend else {
                        return
                    }
                    UserSettings.setLastSendDateOfUserPersonalTrendsToServer(to: Date.now.onlyDate!)
                }
            }
        } else {
            podium.exchangeShareCountStatsWithTheServer { result, _ in
                guard result == .successful || result == .noStatsToSend else {
                    return
                }
                UserSettings.setLastSendDateOfUserPersonalTrendsToServer(to: Date.now.onlyDate!)
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
