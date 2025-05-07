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

    private let contentRepository: ContentRepositoryProtocol
    private let authorService: AuthorServiceProtocol
    private let appMemory: AppPersistentMemoryProtocol

    public var allowSensitive: Bool

    private var searches: [String] = []

    // MARK: - Initializer

    init(
        contentRepository: ContentRepositoryProtocol,
        authorService: AuthorServiceProtocol,
        appMemory: AppPersistentMemoryProtocol,
        allowSensitive: Bool = false
    ) {
        self.contentRepository = contentRepository
        self.authorService = authorService
        self.appMemory = appMemory
        self.allowSensitive = allowSensitive
        self.searches = appMemory.recentSearches() ?? []
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

    func save(searchString: String) {
        guard !searchString.isEmpty else { return }

        if let index = firstIndexOf(searchString: searchString) {
            searches[index] = searchString
        } else if !searches.contains(searchString) {
            searches.insert(searchString, at: 0)
        }

        if searches.count > 3 {
            searches.removeLast()
        }
        appMemory.saveRecentSearches(searches)
    }

    private func firstIndexOf(searchString: String) -> Int? {
        for i in stride(from: 0, to: searches.count, by: 1) {
            if
                searchString.starts(with: searches[i]),
                searches[i].count < searchString.count
            {
                return i
            }
        }
        return nil
    }

    func recentSearches() -> [String] {
        searches
    }
}
