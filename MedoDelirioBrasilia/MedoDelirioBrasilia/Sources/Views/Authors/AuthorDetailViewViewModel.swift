import Combine
import UIKit

class AuthorDetailViewViewModel: ObservableObject {

    @Published var sounds = [Sound]()
    
    @Published var favoritesKeeper = Set<String>()
    @Published var showConfirmationDialog = false
    @Published var soundForConfirmationDialog: Sound? = nil
    
    // Alerts
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    
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
                self.sounds[i].authorName = authorData.first(where: { $0.id == self.sounds[i].authorId })?.name ?? "Desconhecido"
            }
            
            // Populate Favorites Keeper to display favorite cells accordingly
            if let favorites = favorites, favorites.count > 0 {
                for favorite in favorites {
                    favoritesKeeper.insert(favorite.contentId)
                }
            } else {
                favoritesKeeper.removeAll()
            }

            sortSoundsInPlaceByTitleAscending()
        }
    }
    
    private func sortSoundsInPlaceByTitleAscending() {
        self.sounds.sort(by: { $0.title.withoutDiacritics() < $1.title.withoutDiacritics() })
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
        guard filepath.isEmpty == false else {
            return
        }
        
        guard let path = Bundle.main.path(forResource: filepath, ofType: nil) else {
            return showUnableToGetSoundAlert()
        }
        let url = URL(fileURLWithPath: path)
        
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.rootViewController?.present(activityVC, animated: true, completion: nil)
        }
        activityVC.completionWithItemsHandler = { activity, completed, items, error in
            if completed {
                guard let activity = activity else {
                    return
                }
                let destination = ShareDestination.translateFrom(activityTypeRawValue: activity.rawValue)
                Logger.logSharedSound(contentId: contentId, destination: destination, destinationBundleId: activity.rawValue)
                
                AppStoreReviewSteward.requestReviewBasedOnVersionAndCount()
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
    
    func getSoundCount() -> String {
        if sounds.count == 1 {
            return "1 som"
        } else {
            return "\(sounds.count) sons"
        }
    }
    
    func showUnableToGetSoundAlert() {
        alertTitle = "Não Foi Possível Localizar Esse Som"
        alertMessage = "Devido a um problema técnico, o som que você quer acessar não está disponível.\n\nPor favor, nos avise através do botão Conte-nos Por E-mail na aba Ajustes."
        showAlert = true
    }

}
