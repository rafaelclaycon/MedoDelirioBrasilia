import Combine
import UIKit

class SoundsViewViewModel: ObservableObject {
    
    let removeFromFavoritesEmojis = ["🍗","🐂","👴🏻🇧🇷"]

    @Published var sounds = [Sound]()
    
    @Published var sortOption: Int = 0
    @Published var favoritesKeeper = Set<String>()
    @Published var showConfirmationDialog = false
    @Published var soundForConfirmationDialog: Sound? = nil
    @Published var showOnlyFavorites = false
    
    // Alerts
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    
    func reloadList(withSounds allSounds: [Sound],
                    allowSensitiveContent: Bool,
                    favoritesOnly: Bool,
                    sortedBy sortOption: ContentSortOption) {
        var soundsCopy = allSounds
        
        var favorites: [Favorite]?
        favorites = try? database.getAllFavorites()
        
        if favoritesOnly, let favorites = favorites, favorites.count > 0 {
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
                self.sounds[i].authorName = authorData.first(where: { $0.id == self.sounds[i].authorId })?.name ?? "Desconhecido"
            }
            
            // Populate Favorites Keeper to display favorite cells accordingly
            if let favorites = try? database.getAllFavorites(), favorites.count > 0 {
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

    func shareSound(withPath filepath: String) {
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
        let emoji = removeFromFavoritesEmojis.randomElement() ?? ""
        return isSelectedSoundAlreadyAFavorite() ? "\(emoji)  Remover dos Favoritos" : "⭐️  Adicionar aos Favoritos"
    }
    
    func showUnableToGetSoundAlert() {
        alertTitle = "Não Foi Possível Localizar Esse Som"
        alertMessage = "Devido a um problema técnico, o som que você quer acessar não está disponível.\n\nPor favor, nos avise através do botão Conte-nos Por E-mail na aba Ajustes."
        showAlert = true
    }

}
