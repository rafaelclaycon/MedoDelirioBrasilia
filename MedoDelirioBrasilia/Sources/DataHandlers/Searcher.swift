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
        let sounds = try? localDatabase.sounds(matchingDescription: searchString)
        print("RAFA - sounds found: \(sounds?.count)")
        return SearchResults(
            sounds: sounds,
            authors: [],
            folders: [],
            songs: [],
            reactions: []
        )
    }
}
