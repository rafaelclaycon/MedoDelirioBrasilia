//
//  AddChangeHashFieldToUserFolderTable.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 01/11/24.
//

import Foundation
import SQLiteMigrationManager
import SQLite

private typealias Expression = SQLite.Expression

struct AddChangeHashFieldToUserFolderTable: Migration {

    var version: Int64 = 2024_11_01_23_24_00

    private var userFolder = Table("userFolder")

    func migrateDatabase(_ db: Connection) throws {
        try createChangeHashField(db)
    }

    private func createChangeHashField(_ db: Connection) throws {
        let changeHash = Expression<String?>("changeHash")
        try db.run(userFolder.addColumn(changeHash))
    }
}
