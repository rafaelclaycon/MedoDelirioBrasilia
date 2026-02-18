//
//  LocalDatabase+EpisodeFavorite.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 18/02/26.
//

import Foundation
import SQLite

private typealias Expression = SQLite.Expression

extension LocalDatabase {

    func allEpisodeFavoriteIDs() throws -> Set<String> {
        let episodeId = Expression<String>("episodeId")
        var ids = Set<String>()
        for row in try db.prepare(episodeFavoriteTable.select(episodeId)) {
            ids.insert(row[episodeId])
        }
        return ids
    }

    func insertEpisodeFavorite(episodeId: String) throws {
        let episodeIdCol = Expression<String>("episodeId")
        let dateAdded = Expression<Date>("dateAdded")
        try db.run(episodeFavoriteTable.insert(or: .ignore,
            episodeIdCol <- episodeId,
            dateAdded <- Date()
        ))
    }

    func deleteEpisodeFavorite(episodeId: String) throws {
        let episodeIdCol = Expression<String>("episodeId")
        let row = episodeFavoriteTable.filter(episodeIdCol == episodeId)
        try db.run(row.delete())
    }
}
