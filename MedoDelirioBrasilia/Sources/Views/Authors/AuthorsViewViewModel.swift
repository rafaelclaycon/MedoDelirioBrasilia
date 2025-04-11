//
//  AuthorsViewViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 26/05/22.
//

import SwiftUI

extension AuthorsView {

    @Observable final class ViewModel {

        var authors: [Author] = []
        var currentActivity: NSUserActivity? = nil

        // MARK: - Functions

        func reloadList(sortedBy sortOption: AuthorSortOption) {
            guard let allAuthors = try? LocalDatabase.shared.allAuthors() else { return }
            self.authors = allAuthors

            if self.authors.count > 0 {
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

//        func donateActivity() {
//            self.currentActivity = UserActivityWaiter.getDonatableActivity(withType: Shared.viewCollectionsActivityTypeName, andTitle: "Ver Coleções de sons")
//            self.currentActivity?.becomeCurrent()
//        }
    }
}
