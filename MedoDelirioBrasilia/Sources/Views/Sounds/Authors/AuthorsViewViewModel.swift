import Combine
import UIKit

class AuthorsViewViewModel: ObservableObject {

    @Published var authors = [Author]()
    
    @Published var currentActivity: NSUserActivity? = nil
    
    func reloadList() {
//        if UserSettings.getShowOffensiveSounds() {
//            self.sounds = soundData
//        } else {
//            self.sounds = soundData.filter({ $0.isOffensive == false })
//        }
        self.authors = authorData
        
        //self.sortOption = UserSettings.getSoundSortOption()
        
        self.authors.indices.forEach {
            let authorId = self.authors[$0].id
            self.authors[$0].soundCount = soundData.filter({ $0.authorId == authorId }).count
        }
        
        if self.authors.count > 0 {
            //self.authors.sort(by: { $0.name.withoutDiacritics() < $1.name.withoutDiacritics() })
            self.authors.sort(by: { $0.soundCount ?? 0 > $1.soundCount ?? 0 })
        }
    }
    
//    func donateActivity() {
//        self.currentActivity = UserActivityWaiter.getDonatableActivity(withType: Shared.viewCollectionsActivityTypeName, andTitle: "Ver Coleções de sons")
//        self.currentActivity?.becomeCurrent()
//    }

}
