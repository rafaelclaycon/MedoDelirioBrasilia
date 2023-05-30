//
//  AuthorsViewViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 26/05/22.
//

import Foundation
import Combine

class AuthorsViewViewModel: ObservableObject {

    @Published var authors = [Author]()
    
    @Published var currentActivity: NSUserActivity? = nil
    
    func reloadList(sortedBy sortOption: AuthorSortOption) {
        guard let allAuthors = try? database.allAuthors() else { return }
        self.authors = allAuthors
        
        if self.authors.count > 0 {
            self.authors.indices.forEach {
                let authorId = self.authors[$0].id
                // TODO: - Fix this
                self.authors[$0].soundCount = 0 // soundData.filter({ $0.authorId == authorId }).count
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
