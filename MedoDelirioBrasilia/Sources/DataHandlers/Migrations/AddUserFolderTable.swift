import Foundation
import SQLiteMigrationManager
import SQLite

struct AddUserFolderTable: Migration {

    var version: Int64 = 2022_06_21_01_08_00
    
    private var userFolder = Table("userFolder")
    
    func migrateDatabase(_ db: Connection) throws {
        try createUserFolderTable(db)
    }
    
    private func createUserFolderTable(_ db: Connection) throws {
        let id = Expression<String>("id")
        let symbol = Expression<String>("symbol")
        let title = Expression<String>("title")
        let background_color = Expression<String>("backgroundColor")
        
        try db.run(userFolder.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(symbol)
            t.column(title)
            t.column(background_color)
        })
    }

}
