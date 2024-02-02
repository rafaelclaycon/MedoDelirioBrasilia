//
//  AddDateAndVersionToUserFolderTables.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 03/02/23.
//

import Foundation
import SQLiteMigrationManager
import SQLite

// swiftlint:disable identifier_name
struct AddDateAndVersionToUserFolderTables: Migration {

    var version: Int64 = 2023_02_03_18_53_00

    private var userFolder = Table("userFolder")
    private var userFolderContent = Table("userFolderContent")

    func migrateDatabase(_ db: Connection) throws {
        try createDateAddedField(db)
        try createUserFolderFields(db)
    }

    private func createDateAddedField(_ db: Connection) throws {
        let dateAdded = Expression<Date?>("dateAdded")
        try db.run(userFolderContent.addColumn(dateAdded))
    }

    private func createUserFolderFields(_ db: Connection) throws {
        let creationDate = Expression<Date?>("creationDate")
        try db.run(userFolder.addColumn(creationDate))
        let version = Expression<String?>("version")
        try db.run(userFolder.addColumn(version))
        let userSortPreference = Expression<Int?>("userSortPreference")
        try db.run(userFolder.addColumn(userSortPreference))
    }
}
// swiftlint:enable identifier_name
