//
//  FakeSearchService.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 06/05/25.
//

import Foundation

final class FakeSearchService: SearchServiceProtocol {

    var allowSensitive: Bool = true
    
    func results(matching searchString: String) -> SearchResults {
        SearchResults()
    }

    func save(searchString: String) {
        //
    }

    func recentSearches() -> [String] {
        []
    }

    func clearRecentSearches() {
        //
    }
}
