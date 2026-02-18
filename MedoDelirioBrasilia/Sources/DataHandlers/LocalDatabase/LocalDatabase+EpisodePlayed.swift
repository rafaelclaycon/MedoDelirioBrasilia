//
//  LocalDatabase+EpisodePlayed.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 18/02/26.
//

import Foundation
import SQLite

private typealias Expression = SQLite.Expression

extension LocalDatabase {

    func allEpisodePlayedIDs() throws -> Set<String> {
        let episodeId = Expression<String>("episodeId")
        var ids = Set<String>()
        for row in try db.prepare(episodePlayedTable.select(episodeId)) {
            ids.insert(row[episodeId])
        }
        return ids
    }

    func insertEpisodePlayed(episodeId: String) throws {
        let episodeIdCol = Expression<String>("episodeId")
        let dateMarked = Expression<Date>("dateMarked")
        try db.run(episodePlayedTable.insert(or: .ignore,
            episodeIdCol <- episodeId,
            dateMarked <- Date()
        ))
    }

    func deleteEpisodePlayed(episodeId: String) throws {
        let episodeIdCol = Expression<String>("episodeId")
        let row = episodePlayedTable.filter(episodeIdCol == episodeId)
        try db.run(row.delete())
    }
}
