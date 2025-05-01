//
//  SearchService.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 01/05/25.
//

import Foundation

protocol SearchServiceProtocol {

    var allowSensitive: Bool { get set }

    func results(matching searchString: String) -> SearchResults
}

final class SearchService: SearchServiceProtocol {

    private let database: LocalDatabaseProtocol
    private let contentRepository: ContentRepositoryProtocol

    public var allowSensitive: Bool

    // MARK: - Initializer

    init(
        database: LocalDatabaseProtocol,
        contentRepository: ContentRepositoryProtocol,
        allowSensitive: Bool = false
    ) {
        self.database = database
        self.contentRepository = contentRepository
        self.allowSensitive = allowSensitive
    }

    // MARK: - Functions

    func results(matching searchString: String) -> SearchResults {
        return SearchResults(
            content: contentRepository.content(matching: searchString, allowSensitive)
        )
    }
}
