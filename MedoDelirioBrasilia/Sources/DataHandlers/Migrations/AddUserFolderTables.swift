import Foundation
import SQLiteMigrationManager
import SQLite

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
        let title = Expression<String>("title")
        let background_color = Expression<String>("backgroundColor")
        
        try db.run(userFolder.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(symbol)
            t.column(title)
            t.column(background_color)
        })
    }
    
    private func createUserFolderContentTable(_ db: Connection) throws {
        let user_folder_id = Expression<String>("userFolderId")
        let content_id = Expression<String>("contentId")
        
        try db.run(userFolderContent.create(ifNotExists: true) { t in
            t.column(user_folder_id)
            t.column(content_id)
        })
    }

}
