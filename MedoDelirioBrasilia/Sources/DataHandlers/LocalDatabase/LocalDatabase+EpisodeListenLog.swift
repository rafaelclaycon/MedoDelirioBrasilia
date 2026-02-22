//
//  LocalDatabase+EpisodeListenLog.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 17/02/26.
//

import Foundation
import SQLite

private typealias Expression = SQLite.Expression

extension LocalDatabase {

    private var listenIdCol: Expression<String> { Expression<String>("id") }
    private var listenEpisodeIdCol: Expression<String> { Expression<String>("episodeId") }
    private var startedAtCol: Expression<Date> { Expression<Date>("startedAt") }
    private var endedAtCol: Expression<Date> { Expression<Date>("endedAt") }
    private var durationListenedCol: Expression<Double> { Expression<Double>("durationListened") }
    private var didCompleteCol: Expression<Bool> { Expression<Bool>("didComplete") }

    func insertEpisodeListenLog(_ log: EpisodeListenLog) throws {
        try db.run(episodeListenLogTable.insert(
            listenIdCol <- log.id,
            listenEpisodeIdCol <- log.episodeId,
            startedAtCol <- log.startedAt,
            endedAtCol <- log.endedAt,
            durationListenedCol <- log.durationListened,
            didCompleteCol <- log.didComplete
        ))
    }

    func allEpisodeListenLogs() throws -> [EpisodeListenLog] {
        var logs = [EpisodeListenLog]()
        for row in try db.prepare(episodeListenLogTable.order(startedAtCol.desc)) {
            logs.append(
                EpisodeListenLog(
                    id: row[listenIdCol],
                    episodeId: row[listenEpisodeIdCol],
                    startedAt: row[startedAtCol],
                    endedAt: row[endedAtCol],
                    durationListened: row[durationListenedCol],
                    didComplete: row[didCompleteCol]
                )
            )
        }
        return logs
    }

    func episodeListenLogs(forEpisodeId episodeId: String) throws -> [EpisodeListenLog] {
        let query = episodeListenLogTable
            .filter(listenEpisodeIdCol == episodeId)
            .order(startedAtCol.desc)

        var logs = [EpisodeListenLog]()
        for row in try db.prepare(query) {
            logs.append(
                EpisodeListenLog(
                    id: row[listenIdCol],
                    episodeId: row[listenEpisodeIdCol],
                    startedAt: row[startedAtCol],
                    endedAt: row[endedAtCol],
                    durationListened: row[durationListenedCol],
                    didComplete: row[didCompleteCol]
                )
            )
        }
        return logs
    }

    func allListenDates() throws -> [Date] {
        var dates = [Date]()
        for row in try db.prepare(episodeListenLogTable.select(startedAtCol)) {
            dates.append(row[startedAtCol])
        }
        return dates
    }

    func deleteAllEpisodeListenLogs() throws {
        try db.run(episodeListenLogTable.delete())
    }
}
