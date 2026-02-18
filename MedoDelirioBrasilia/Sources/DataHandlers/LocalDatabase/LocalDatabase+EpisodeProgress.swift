//
//  LocalDatabase+EpisodeProgress.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 18/02/26.
//

import Foundation
import SQLite

private typealias Expression = SQLite.Expression

extension LocalDatabase {

    func allEpisodeProgress() throws -> [String: (currentTime: Double, duration: Double)] {
        let episodeId = Expression<String>("episodeId")
        let currentTime = Expression<Double>("currentTime")
        let duration = Expression<Double>("duration")

        var result = [String: (currentTime: Double, duration: Double)]()
        for row in try db.prepare(episodeProgressTable) {
            result[row[episodeId]] = (currentTime: row[currentTime], duration: row[duration])
        }
        return result
    }

    func upsertEpisodeProgress(episodeId: String, currentTime: Double, duration: Double) throws {
        let episodeIdCol = Expression<String>("episodeId")
        let currentTimeCol = Expression<Double>("currentTime")
        let durationCol = Expression<Double>("duration")
        let updatedAt = Expression<Date>("updatedAt")

        try db.run(episodeProgressTable.insert(or: .replace,
            episodeIdCol <- episodeId,
            currentTimeCol <- currentTime,
            durationCol <- duration,
            updatedAt <- Date()
        ))
    }

    func deleteEpisodeProgress(episodeId: String) throws {
        let episodeIdCol = Expression<String>("episodeId")
        let row = episodeProgressTable.filter(episodeIdCol == episodeId)
        try db.run(row.delete())
    }
}
