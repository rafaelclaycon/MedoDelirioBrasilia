import Foundation
import SQLite
import SQLiteMigrationManager

internal protocol LocalDatabaseProtocol {

    func contentExistsInsideUserFolder(withId folderId: String, contentId: String) throws -> Bool

}

class LocalDatabase: LocalDatabaseProtocol {

    var db: Connection
    var migrationManager: SQLiteMigrationManager
    
    var favorite = Table("favorite")
    var userShareLog = Table("userShareLog")
    var audienceSharingStatistic = Table("audienceSharingStatistic")
    var networkCallLog = Table("networkCallLog")
    var userFolder = Table("userFolder")
    var userFolderContent = Table("userFolderContent")
    
    // MARK: - Setup
    
    init() {
        do {
            db = try Connection(LocalDatabase.databaseFilepath())
        } catch {
            fatalError(error.localizedDescription)
        }
        
        self.migrationManager = SQLiteMigrationManager(db: self.db, migrations: LocalDatabase.migrations())
    }
    
    func migrateIfNeeded() throws {
        if !migrationManager.hasMigrationsTable() {
            try migrationManager.createMigrationsTable()
        }

        if migrationManager.needsMigration() {
            try migrationManager.migrateDatabase()
        }
    }

}

extension LocalDatabase {

    static func databaseFilepath() -> String {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first!
        return "\(path)/medo_db.sqlite3"
    }
    
    static func migrations() -> [Migration] {
        return [InitialMigration(),
                AddNetworkCallLogTable(),
                AddUserFolderTables(),
                RemoveFavoriteLogTable(),
                AddAudienceSharingStatisticTable(),
                AddRankingTypeToAudienceSharingStatisticTable()]
    }
    
    var needsMigration: Bool {
        return migrationManager.needsMigration()
    }

}

extension LocalDatabase: CustomStringConvertible {

    var description: String {
        return "Database:\n" +
        "url: \(LocalDatabase.databaseFilepath())\n" +
        "migration state:\n" +
        "  hasMigrationsTable() \(migrationManager.hasMigrationsTable())\n" +
        "  currentVersion()     \(migrationManager.currentVersion())\n" +
        "  originVersion()      \(migrationManager.originVersion())\n" +
        "  appliedVersions()    \(migrationManager.appliedVersions())\n" +
        "  pendingMigrations()  \(migrationManager.pendingMigrations())\n" +
        "  needsMigration()     \(migrationManager.needsMigration())"
    }

}

enum LocalDatabaseError: Error {

    case favoriteNotFound
    case folderNotFound
    case folderContentNotFound
    case internalError

}
