import Foundation
import SQLiteMigrationManager
import SQLite

struct RemoveFavoriteLogTable: Migration {

    var version: Int64 = 2022_10_12_09_28_00
    
    private var favoriteLog = Table("favoriteLog")
    
    func migrateDatabase(_ db: Connection) throws {
        try removeFavoriteLogTable(db)
    }
    
    private func removeFavoriteLogTable(_ db: Connection) throws {
        try db.run(favoriteLog.drop(ifExists: true))
    }

}
