//
//  AddSoundAndAuthorTables.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 27/04/23.
//

import Foundation
import SQLiteMigrationManager
import SQLite

// swiftlint:disable identifier_name
struct AddSyncTables: Migration {

    var version: Int64 = 2023_04_27_21_02_00

    private var soundTable = Table("sound")
    private var authorTable = Table("author")
    private var updateEventTable = Table("updateEvent")
    private var syncLogTable = Table("syncLog")

    func migrateDatabase(_ db: Connection) throws {
        try createSoundTable(db)
        try createAuthorTable(db)
        try createUpdateEventTable(db)
        try createSyncLogTable(db)
    }

    private func createSoundTable(_ db: Connection) throws {
        let id = Expression<String>("id")
        let title = Expression<String>("title")
        let authorId = Expression<String>("authorId")
        let description = Expression<String>("description")
        let filename = Expression<String>("filename")
        let dateAdded = Expression<Date?>("dateAdded")
        let duration = Expression<Double>("duration")
        let isOffensive = Expression<Bool>("isOffensive")
        let isFromServer = Expression<Bool?>("isFromServer")

        try db.run(soundTable.create(ifNotExists: true) { table in
            table.column(id, primaryKey: true)
            table.column(title)
            table.column(authorId)
            table.column(description)
            table.column(filename)
            table.column(dateAdded)
            table.column(duration)
            table.column(isOffensive)
            table.column(isFromServer)
        })
    }

    private func createAuthorTable(_ db: Connection) throws {
        let id = Expression<String>("id")
        let name = Expression<String>("name")
        let photo = Expression<String?>("photo")
        let description = Expression<String?>("description")

        try db.run(authorTable.create(ifNotExists: true) { table in
            table.column(id, primaryKey: true)
            table.column(name)
            table.column(photo)
            table.column(description)
        })
    }

    private func createUpdateEventTable(_ db: Connection) throws {
        let id = Expression<UUID>("id")
        let contentId = Expression<String>("contentId")
        let dateTime = Expression<String>("dateTime")
        let mediaType = Expression<Int>("mediaType")
        let eventType = Expression<Int>("eventType")
        let didSucceed = Expression<Bool?>("didSucceed")

        try db.run(updateEventTable.create(ifNotExists: true) { table in
            table.column(id, primaryKey: true)
            table.column(contentId)
            table.column(dateTime)
            table.column(mediaType)
            table.column(eventType)
            table.column(didSucceed)
        })
    }

    private func createSyncLogTable(_ db: Connection) throws {
        let id = Expression<String>("id")
        let logType = Expression<String>("logType")
        let description = Expression<String>("description")
        let dateTime = Expression<String>("dateTime")
        let installId = Expression<String>("installId")
        let systemName = Expression<String>("systemName")
        let systemVersion = Expression<String>("systemVersion")
        let isiOSAppOnMac = Expression<Bool>("isiOSAppOnMac")
        let appVersion = Expression<String>("appVersion")
        let currentTimeZone = Expression<String>("currentTimeZone")
        let updateEventId = Expression<String>("updateEventId")

        try db.run(syncLogTable.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(logType)
            t.column(description)
            t.column(dateTime)
            t.column(installId)
            t.column(systemName)
            t.column(systemVersion)
            t.column(isiOSAppOnMac)
            t.column(appVersion)
            t.column(currentTimeZone)
            t.column(updateEventId)
        })
    }
}
// swiftlint:enable identifier_name
