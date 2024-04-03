//
//  AddExternalLinksFieldToAuthorTable.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 28/03/24.
//

import Foundation
import SQLiteMigrationManager
import SQLite

struct AddExternalLinksFieldToAuthorTable: Migration {

    var version: Int64 = 2024_03_28_18_21_00

    private var author = Table("author")

    func migrateDatabase(_ db: Connection) throws {
        try createExternalLinksField(db)
    }

    private func createExternalLinksField(_ db: Connection) throws {
        let externalLinks = Expression<String?>("externalLinks")
        try db.run(author.addColumn(externalLinks))
    }
}
