import Combine
import UIKit

class AuthorsViewViewModel: ObservableObject {

    @Published var authors = [Author]()
    
    func reloadList() {
//        if UserSettings.getShowOffensiveSounds() {
//            self.sounds = soundData
//        } else {
//            self.sounds = soundData.filter({ $0.isOffensive == false })
//        }
        self.authors = authorData
        
        //self.sortOption = UserSettings.getSoundSortOption()
        
        if self.authors.count > 0 {
            self.authors.sort(by: { $0.name.withoutDiacritics() < $1.name.withoutDiacritics() })
        }
    }

}
