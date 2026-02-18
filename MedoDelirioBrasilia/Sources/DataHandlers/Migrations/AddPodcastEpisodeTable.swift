//
//  AddPodcastEpisodeTable.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 18/02/26.
//

import Foundation
import SQLiteMigrationManager
import SQLite

private typealias Expression = SQLite.Expression

struct AddPodcastEpisodeTable: Migration {

    var version: Int64 = 2026_02_18_12_00_00

    private var podcastEpisode = Table("podcastEpisode")

    func migrateDatabase(_ db: Connection) throws {
        let id = Expression<String>("id")
        let title = Expression<String>("title")
        let pubDate = Expression<Date>("pubDate")
        let audioURL = Expression<String>("audioURL")
        let description = Expression<String?>("description")
        let imageURL = Expression<String?>("imageURL")
        let duration = Expression<Double?>("duration")
        let isExplicit = Expression<Bool>("isExplicit")

        try db.run(podcastEpisode.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(title)
            t.column(pubDate)
            t.column(audioURL)
            t.column(description)
            t.column(imageURL)
            t.column(duration)
            t.column(isExplicit, defaultValue: false)
        })
    }
}
