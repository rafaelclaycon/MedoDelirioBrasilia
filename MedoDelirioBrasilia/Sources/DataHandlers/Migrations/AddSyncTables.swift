//
//  AddSoundAndAuthorTables.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 27/04/23.
//

import Foundation
import SQLiteMigrationManager
import SQLite

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
        let author_id = Expression<String>("authorId")
        let description = Expression<String>("description")
        let filename = Expression<String>("filename")
        let date_added = Expression<Date?>("dateAdded")
        let duration = Expression<Double>("duration")
        let is_offensive = Expression<Bool>("isOffensive")
        let is_from_server = Expression<Bool?>("isFromServer")
        
        try db.run(soundTable.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(title)
            t.column(author_id)
            t.column(description)
            t.column(filename)
            t.column(date_added)
            t.column(duration)
            t.column(is_offensive)
            t.column(is_from_server)
        })
    }
    
    private func createAuthorTable(_ db: Connection) throws {
        let id = Expression<String>("id")
        let name = Expression<String>("name")
        let photo = Expression<String?>("photo")
        let description = Expression<String?>("description")
        
        try db.run(authorTable.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(name)
            t.column(photo)
            t.column(description)
        })
    }
    
    private func createUpdateEventTable(_ db: Connection) throws {
        let id = Expression<UUID>("id")
        let content_id = Expression<String>("contentId")
        let date_time = Expression<String>("dateTime")
        let media_type = Expression<Int>("mediaType")
        let event_type = Expression<Int>("eventType")
        let did_succeed = Expression<Bool?>("didSucceed")
        
        try db.run(updateEventTable.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(content_id)
            t.column(date_time)
            t.column(media_type)
            t.column(event_type)
            t.column(did_succeed)
        })
    }
    
    private func createSyncLogTable(_ db: Connection) throws {
        let id = Expression<String>("id")
        let log_type = Expression<String>("logType")
        let description = Expression<String>("description")
        let date_time = Expression<String>("dateTime")
        let install_id = Expression<String>("installId")
        let system_name = Expression<String>("systemName")
        let system_version = Expression<String>("systemVersion")
        let is_ios_app_on_mac = Expression<Bool>("isiOSAppOnMac")
        let app_version = Expression<String>("appVersion")
        let current_time_zone = Expression<String>("currentTimeZone")
        let update_event_id = Expression<String>("updateEventId")
        
        try db.run(syncLogTable.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(log_type)
            t.column(description)
            t.column(date_time)
            t.column(install_id)
            t.column(system_name)
            t.column(system_version)
            t.column(is_ios_app_on_mac)
            t.column(app_version)
            t.column(current_time_zone)
            t.column(update_event_id)
        })
    }
}
