import Foundation
import SQLiteMigrationManager
import SQLite

// swiftlint:disable identifier_name
struct AddUserFolderTables: Migration {

    var version: Int64 = 2022_06_21_01_08_00

    private var userFolder = Table("userFolder")
    private var userFolderContent = Table("userFolderContent")

    func migrateDatabase(_ db: Connection) throws {
        try createUserFolderTable(db)
        try createUserFolderContentTable(db)
    }

    private func createUserFolderTable(_ db: Connection) throws {
        let id = Expression<String>("id")
        let symbol = Expression<String>("symbol")
        let name = Expression<String>("name")
        let backgroundColor = Expression<String>("backgroundColor")

        try db.run(userFolder.create(ifNotExists: true) { table in
            table.column(id, primaryKey: true)
            table.column(symbol)
            table.column(name)
            table.column(backgroundColor)
        })
    }

    private func createUserFolderContentTable(_ db: Connection) throws {
        let userFolderId = Expression<String>("userFolderId")
        let contentId = Expression<String>("contentId")

        try db.run(userFolderContent.create(ifNotExists: true) { table in
            table.column(userFolderId)
            table.column(contentId)
        })
    }
}
// swiftlint:enable identifier_name
