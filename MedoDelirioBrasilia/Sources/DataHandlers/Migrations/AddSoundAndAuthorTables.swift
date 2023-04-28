//
//  AddSoundAndAuthorTables.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 27/04/23.
//

import Foundation
import SQLiteMigrationManager
import SQLite

struct AddSoundAndAuthorTables: Migration {
    
    var version: Int64 = 2023_04_27_21_02_00
    
    private var sound = Table("sound")
    private var author = Table("author")
    
    func migrateDatabase(_ db: Connection) throws {
        try createSoundTable(db)
        try createAuthorTable(db)
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
        let is_new = Expression<Bool?>("isNew")
        let is_from_server = Expression<Bool?>("isFromServer")
        
        try db.run(sound.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(title)
            t.column(author_id)
            t.column(description)
            t.column(filename)
            t.column(date_added)
            t.column(duration)
            t.column(is_offensive)
            t.column(is_new)
            t.column(is_from_server)
        })
    }
    
    private func createAuthorTable(_ db: Connection) throws {
        let id = Expression<String>("id")
        let name = Expression<String>("name")
        let photo = Expression<String?>("photo")
        let description = Expression<String?>("description")
        
        try db.run(author.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(name)
            t.column(photo)
            t.column(description)
        })
    }
}
