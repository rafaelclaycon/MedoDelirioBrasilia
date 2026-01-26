//
//  SearchService.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 01/05/25.
//

import Foundation

protocol SearchServiceProtocol {

    var reactionsState: LoadingState<[Reaction]> { get }

    func results(matching searchString: String) -> SearchResults
    func loadReactions() async

    func save(searchString: String)
    func recentSearches() -> [String]
    func clearRecentSearches()
}

final class SearchService: SearchServiceProtocol {

    private let contentRepository: ContentRepositoryProtocol
    private let authorService: AuthorServiceProtocol
    private let appMemory: AppPersistentMemoryProtocol
    private let userFolderRepository: UserFolderRepositoryProtocol
    private let userSettings: UserSettingsProtocol
    private let reactionRepository: ReactionRepositoryProtocol

    private var searches: [String] = []
    private(set) var reactionsState: LoadingState<[Reaction]> = .loading
    private var saveWorkItem: DispatchWorkItem?
    private var reactionsLoadedAt: Date?

    private let reactionsCacheMaxAge: TimeInterval = 30 * 60 // 30 minutes

    // MARK: - Initializer

    init(
        contentRepository: ContentRepositoryProtocol,
        authorService: AuthorServiceProtocol,
        appMemory: AppPersistentMemoryProtocol,
        userFolderRepository: UserFolderRepositoryProtocol,
        userSettings: UserSettingsProtocol,
        reactionRepository: ReactionRepositoryProtocol
    ) {
        self.contentRepository = contentRepository
        self.authorService = authorService
        self.appMemory = appMemory
        self.userFolderRepository = userFolderRepository
        self.userSettings = userSettings
        self.reactionRepository = reactionRepository
        self.searches = appMemory.recentSearches() ?? []
    }

    // MARK: - Functions

    func results(matching searchString: String) -> SearchResults {
        save(searchString: searchString)
        let allowSensitive = userSettings.getShowExplicitContent()
        return SearchResults(
            soundsMatchingTitle: contentRepository.sounds(matchingTitle: searchString, allowSensitive),
            soundsMatchingContent: contentRepository.sounds(matchingDescription: searchString, allowSensitive),
            songsMatchingTitle: contentRepository.songs(matchingTitle: searchString, allowSensitive),
            songsMatchingContent: contentRepository.songs(matchingDescription: searchString, allowSensitive),
            authors: authorService.authors(matchingName: searchString),
            folders: userFolderRepository.folders(matchingName: searchString),
            reactionsMatchingTitle: reactions(matchingTitle: searchString)
        )
    }

    func loadReactions() async {
        // Skip if recently loaded and still valid
        if let loadedAt = reactionsLoadedAt,
           Date().timeIntervalSince(loadedAt) < reactionsCacheMaxAge,
           case .loaded = reactionsState {
            return
        }

        reactionsState = .loading
        do {
            let reactions = try await reactionRepository.allReactions()
            reactionsState = .loaded(reactions)
            reactionsLoadedAt = Date()
        } catch {
            reactionsState = .error(error.localizedDescription)
        }
    }

    func save(searchString: String) {
        guard !searchString.isEmpty else { return }

        // Update in-memory array immediately
        if let index = firstIndexOf(searchString: searchString) {
            guard searches[index].count < searchString.count else { return }
            searches.remove(at: index)
            searches.insert(searchString, at: 0)
        } else {
            searches.insert(searchString, at: 0)
        }

        if searches.count > 3 {
            searches.removeLast()
        }

        // Debounce the disk write
        saveWorkItem?.cancel()
        saveWorkItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            self.appMemory.saveRecentSearches(self.searches)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: saveWorkItem!)
    }

    func recentSearches() -> [String] {
        searches
    }

    func clearRecentSearches() {
        searches = []
        appMemory.saveRecentSearches([])
    }

    /// Immediately executes any pending save operation. Useful for testing.
    func flushPendingSave() {
        saveWorkItem?.perform()
        saveWorkItem = nil
    }
}

// MARK: - Internal Functions

extension SearchService {

    private func firstIndexOf(searchString: String) -> Int? {
        for i in stride(from: 0, to: searches.count, by: 1) {
            if
                searches[i].starts(with: searchString) ||
                searchString.contains(searches[i])
            {
                return i
            }
        }
        return nil
    }

    private func reactions(matchingTitle title: String) -> [Reaction]? {
        guard case .loaded(let reactions) = reactionsState else { return nil }
        return reactions.filter {
            $0.title.lowercased().withoutDiacritics()
                .contains(title.lowercased().withoutDiacritics())
        }
    }
}
