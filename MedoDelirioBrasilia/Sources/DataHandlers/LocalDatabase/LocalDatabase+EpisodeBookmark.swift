//
//  LocalDatabase+EpisodeBookmark.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 18/02/26.
//

import Foundation
import SQLite

private typealias Expression = SQLite.Expression

extension LocalDatabase {

    private var idCol: Expression<String> { Expression<String>("id") }
    private var episodeIdCol: Expression<String> { Expression<String>("episodeId") }
    private var timestampCol: Expression<Double> { Expression<Double>("timestamp") }
    private var titleCol: Expression<String?> { Expression<String?>("title") }
    private var noteCol: Expression<String?> { Expression<String?>("note") }
    private var createdAtCol: Expression<Date> { Expression<Date>("createdAt") }

    func allBookmarks(forEpisodeId episodeId: String) throws -> [EpisodeBookmark] {
        let query = episodeBookmarkTable
            .filter(episodeIdCol == episodeId)
            .order(timestampCol.asc)

        var bookmarks = [EpisodeBookmark]()
        for row in try db.prepare(query) {
            bookmarks.append(
                EpisodeBookmark(
                    id: row[idCol],
                    episodeId: row[episodeIdCol],
                    timestamp: row[timestampCol],
                    title: row[titleCol],
                    note: row[noteCol],
                    createdAt: row[createdAtCol]
                )
            )
        }
        return bookmarks
    }

    func allBookmarkedEpisodeIDs() throws -> Set<String> {
        let query = episodeBookmarkTable.select(distinct: episodeIdCol)
        var ids = Set<String>()
        for row in try db.prepare(query) {
            ids.insert(row[episodeIdCol])
        }
        return ids
    }

    func allBookmarkDates() throws -> [Date] {
        let query = episodeBookmarkTable
            .select(createdAtCol)
            .order(createdAtCol.asc)

        var dates = [Date]()
        for row in try db.prepare(query) {
            dates.append(row[createdAtCol])
        }
        return dates
    }

    func insertBookmark(_ bookmark: EpisodeBookmark) throws {
        try db.run(episodeBookmarkTable.insert(
            idCol <- bookmark.id,
            episodeIdCol <- bookmark.episodeId,
            timestampCol <- bookmark.timestamp,
            titleCol <- bookmark.title,
            noteCol <- bookmark.note,
            createdAtCol <- bookmark.createdAt
        ))
    }

    func updateBookmark(_ bookmark: EpisodeBookmark) throws {
        let row = episodeBookmarkTable.filter(idCol == bookmark.id)
        try db.run(row.update(
            titleCol <- bookmark.title,
            noteCol <- bookmark.note
        ))
    }

    func deleteBookmark(id: String) throws {
        let row = episodeBookmarkTable.filter(idCol == id)
        try db.run(row.delete())
    }
}
