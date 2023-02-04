//
//  AddDateAndVersionToUserFolderTables.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 03/02/23.
//

import Foundation
import SQLiteMigrationManager
import SQLite

struct AddDateAndVersionToUserFolderTables: Migration {

    var version: Int64 = 2023_02_03_18_53_00
    
    private var userFolder = Table("userFolder")
    private var userFolderContent = Table("userFolderContent")
    
    func migrateDatabase(_ db: Connection) throws {
        try createDateAddedField(db)
        try createCreationDateAndVersionFields(db)
    }
    
    private func createDateAddedField(_ db: Connection) throws {
        let date_added = Expression<Date?>("dateAdded")
        try db.run(userFolderContent.addColumn(date_added))
    }
    
    private func createCreationDateAndVersionFields(_ db: Connection) throws {
        let creation_date = Expression<Date?>("creationDate")
        try db.run(userFolder.addColumn(creation_date))
        let version = Expression<String?>("version")
        try db.run(userFolder.addColumn(version))
    }

}
