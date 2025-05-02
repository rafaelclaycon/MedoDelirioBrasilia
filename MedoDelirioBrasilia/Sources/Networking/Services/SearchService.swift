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
    private let authorService: AuthorServiceProtocol

    public var allowSensitive: Bool

    // MARK: - Initializer

    init(
        database: LocalDatabaseProtocol,
        contentRepository: ContentRepositoryProtocol,
        authorService: AuthorServiceProtocol,
        allowSensitive: Bool = false
    ) {
        self.database = database
        self.contentRepository = contentRepository
        self.authorService = authorService
        self.allowSensitive = allowSensitive
    }

    // MARK: - Functions

    func results(matching searchString: String) -> SearchResults {
        return SearchResults(
            soundsMatchingTitle: contentRepository.sounds(matchingTitle: searchString, allowSensitive),
            soundsMatchingContent: contentRepository.sounds(matchingDescription: searchString, allowSensitive),
            songsMatchingTitle: contentRepository.songs(matchingTitle: searchString, allowSensitive),
            songsMatchingContent: contentRepository.songs(matchingDescription: searchString, allowSensitive),
            authors: authorService.authors(matchingName: searchString)
        )
    }
}
