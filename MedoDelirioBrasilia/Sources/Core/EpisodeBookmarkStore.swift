//
//  EpisodeBookmarkStore.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 18/02/26.
//

import Foundation

@Observable
final class EpisodeBookmarkStore {

    @ObservationIgnored private let database: LocalDatabaseProtocol

    private(set) var bookmarksByEpisode: [String: [EpisodeBookmark]] = [:]

    init(database: LocalDatabaseProtocol = LocalDatabase.shared) {
        self.database = database
    }

    // MARK: - Public API

    func episodeIdsWithBookmarks() -> Set<String> {
        (try? database.allBookmarkedEpisodeIDs()) ?? []
    }

    func bookmarks(for episodeId: String) -> [EpisodeBookmark] {
        if let cached = bookmarksByEpisode[episodeId] {
            return cached
        }
        let loaded = (try? database.allBookmarks(forEpisodeId: episodeId)) ?? []
        bookmarksByEpisode[episodeId] = loaded
        return loaded
    }

    @discardableResult
    func addBookmark(episodeId: String, timestamp: TimeInterval) -> EpisodeBookmark {
        let bookmark = EpisodeBookmark(episodeId: episodeId, timestamp: timestamp)
        try? database.insertBookmark(bookmark)

        var list = bookmarksByEpisode[episodeId] ?? []
        list.append(bookmark)
        list.sort { $0.timestamp < $1.timestamp }
        bookmarksByEpisode[episodeId] = list

        return bookmark
    }

    func update(_ bookmark: EpisodeBookmark) {
        try? database.updateBookmark(bookmark)

        if var list = bookmarksByEpisode[bookmark.episodeId],
           let index = list.firstIndex(where: { $0.id == bookmark.id }) {
            list[index] = bookmark
            bookmarksByEpisode[bookmark.episodeId] = list
        }
    }

    func delete(id: String, episodeId: String) {
        try? database.deleteBookmark(id: id)

        if var list = bookmarksByEpisode[episodeId] {
            list.removeAll { $0.id == id }
            bookmarksByEpisode[episodeId] = list
        }
    }
}
