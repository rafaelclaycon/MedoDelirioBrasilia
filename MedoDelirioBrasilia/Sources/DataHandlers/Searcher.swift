//
//  Searcher.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 20/01/25.
//

import Foundation

final class Searcher {

    private let localDatabase: LocalDatabaseProtocol

    init(
        localDatabase: LocalDatabaseProtocol
    ) {
        self.localDatabase = localDatabase
    }

    public func searchFor(_ searchString: String) -> SearchResults {
        return SearchResults(
            sounds: try? localDatabase.sounds(matchingDescription: searchString),
            authors: [],
            folders: [],
            songs: [],
            reactions: []
        )
    }
}
