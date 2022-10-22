//
//  AuthorsViewViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 26/05/22.
//

import Combine
import UIKit

class AuthorsViewViewModel: ObservableObject {

    @Published var authors = [Author]()
    
    @Published var currentActivity: NSUserActivity? = nil
    
    func reloadList(sortedBy sortOption: AuthorSortOption) {
        self.authors = authorData
        
        if self.authors.count > 0 {
            self.authors.indices.forEach {
                let authorId = self.authors[$0].id
                self.authors[$0].soundCount = soundData.filter({ $0.authorId == authorId }).count
            }
            
            switch sortOption {
            case .nameAscending:
                sortAuthorsInPlaceByNameAscending()
            case .soundCountDescending:
                sortAuthorsInPlaceBySoundCountDescending()
            case .soundCountAscending:
                sortAuthorsInPlaceBySoundCountAscending()
            }
        }
    }
    
    func sortAuthorsInPlaceByNameAscending() {
        self.authors.sort(by: { $0.name.withoutDiacritics() < $1.name.withoutDiacritics() })
    }
    
    func sortAuthorsInPlaceBySoundCountDescending() {
        self.authors.sort(by: { $0.soundCount ?? 0 > $1.soundCount ?? 0 })
    }
    
    func sortAuthorsInPlaceBySoundCountAscending() {
        self.authors.sort(by: { $0.soundCount ?? 0 < $1.soundCount ?? 0 })
    }
    
//    func donateActivity() {
//        self.currentActivity = UserActivityWaiter.getDonatableActivity(withType: Shared.viewCollectionsActivityTypeName, andTitle: "Ver Coleções de sons")
//        self.currentActivity?.becomeCurrent()
//    }

}
