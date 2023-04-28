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
        let symbol = Expression<String>("symbol")
        let name = Expression<String>("name")
        let background_color = Expression<String>("backgroundColor")
        
        try db.run(userFolder.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(symbol)
            t.column(name)
            t.column(background_color)
        })
    }
    
    private func createAuthorTable(_ db: Connection) throws {
        let id = Expression<String>("id")
        let symbol = Expression<String>("symbol")
        let name = Expression<String>("name")
        let background_color = Expression<String>("backgroundColor")
        
        try db.run(userFolder.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(symbol)
            t.column(name)
            t.column(background_color)
        })
    }
}
