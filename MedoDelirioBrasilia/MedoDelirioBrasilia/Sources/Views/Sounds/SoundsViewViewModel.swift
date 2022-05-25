import Combine
import UIKit

class SoundsViewViewModel: ObservableObject {

    @Published var sounds = [Sound]()
    @Published var sortOption: Int = 0
    @Published var favoritesKeeper = Set<String>()
    @Published var showConfirmationDialog = false
    @Published var soundForConfirmationDialog: Sound? = nil
    
    func reloadList() {
        if UserSettings.getShowOffensiveSounds() {
            self.sounds = soundData
        } else {
            self.sounds = soundData.filter({ $0.isOffensive == false })
        }
        
        self.sortOption = 0 //UserSettings.getArchiveSortOption()
        
        if self.sounds.count > 0 {
            // Needed because author names live in a different file.
            for i in 0...(self.sounds.count - 1) {
                self.sounds[i].authorName = authorData.first(where: { $0.id == self.sounds[i].authorId })?.name ?? "Desconhecido"
            }
            
            if let favorites = try? database.getAllFavorites(), favorites.count > 0 {
                for favorite in favorites {
                    favoritesKeeper.insert(favorite.contentId)
                }
            } else {
                favoritesKeeper.removeAll()
            }
            
            self.sounds.sort(by: { $0.title.withoutDiacritics() < $1.title.withoutDiacritics() })
        }
    }
    
    func playSound(fromPath filepath: String) {
        guard filepath.isEmpty == false else {
            return
        }
        
        let path = Bundle.main.path(forResource: filepath, ofType: nil)!
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
        
        let path = Bundle.main.path(forResource: filepath, ofType: nil)!
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

}
