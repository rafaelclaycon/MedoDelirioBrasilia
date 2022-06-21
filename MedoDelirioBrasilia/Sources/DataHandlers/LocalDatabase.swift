import Foundation
import SQLite
import SQLiteMigrationManager

internal protocol LocalDatabaseProtocol {

    func checkServerStatus(completionHandler: @escaping (Bool, String) -> Void)
    func getSoundShareCountStats(completionHandler: @escaping ([ServerShareCountStat]?, NetworkRabbitError?) -> Void)
    func post(shareCountStat: ServerShareCountStat, completionHandler: @escaping (String) -> Void)
    func post(clientDeviceInfo: ClientDeviceInfo, completionHandler: @escaping (Bool?, NetworkRabbitError?) -> Void)

}

class LocalDatabase {

    var db: Connection
    var migrationManager: SQLiteMigrationManager
    
    var favorite = Table("favorite")
    var userShareLog = Table("userShareLog")
    var audienceSharingStatistic = Table("audienceSharingStatistic")
    var networkCallLog = Table("networkCallLog")
    var userFolder = Table("userFolder")
    
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
    
    // MARK: - Favorite

    func getFavoriteCount() throws -> Int {
        try db.scalar(favorite.count)
    }

    func insert(favorite newFavorite: Favorite) throws {
        let insert = try favorite.insert(newFavorite)
        try db.run(insert)
    }

    func getAllFavorites() throws -> [Favorite] {
        var queriedFavorites = [Favorite]()

        for queriedFavorite in try db.prepare(favorite) {
            queriedFavorites.append(try queriedFavorite.decode())
        }
        return queriedFavorites
    }

    func deleteAllFavorites() throws {
        try db.run(favorite.delete())
    }
    
    func deleteFavorite(withId contentId: String) throws {
        let id = Expression<String>("contentId")
        let specificFavorite = favorite.filter(id == contentId)
        if try db.run(specificFavorite.delete()) == 0 {
            throw LocalDatabaseError.favoriteNotFound
        }
    }
    
    func exists(contentId: String) throws -> Bool {
        var queriedFavorites = [Favorite]()

        let id = Expression<String>("contentId")
        let query = favorite.filter(id == contentId)

        for queriedFavorite in try db.prepare(query) {
            queriedFavorites.append(try queriedFavorite.decode())
        }
        return queriedFavorites.count > 0
    }
    
    // MARK: - Personal Top Chart
    
    func getTop5SoundsSharedByTheUser() throws -> [TopChartItem] {
        var result = [TopChartItem]()
        let content_id = Expression<String>("contentId")
        let content_type = Expression<Int>("contentType")
        
        let contentCount = content_id.count
        for row in try db.prepare(userShareLog
                                      .select(content_id,contentCount)
                                      .where(content_type == 0)
                                      .group(content_id)
                                      .order(contentCount.desc)
                                      .limit(5)) {
            result.append(TopChartItem(id: .empty,
                                       contentId: row[content_id],
                                       contentName: .empty,
                                       contentAuthorId: .empty,
                                       contentAuthorName: .empty,
                                       shareCount: row[contentCount]))
        }
        return result
    }
    
    // MARK: - Audience Top Chart
    
    func getTop5SoundsSharedByTheAudience() throws -> [TopChartItem] {
        var result = [TopChartItem]()
        let content_id = Expression<String>("contentId")
        let content_type = Expression<Int>("contentType")
        let share_count = Expression<Int>("shareCount")
        
        let totalShareCount = share_count.sum
        for row in try db.prepare(audienceSharingStatistic
                                      .select(content_id,totalShareCount)
                                      .where(content_type == 0)
                                      .group(content_id)
                                      .order(totalShareCount.desc)
                                      .limit(5)) {
            result.append(TopChartItem(id: .empty,
                                       contentId: row[content_id],
                                       contentName: .empty,
                                       contentAuthorId: .empty,
                                       contentAuthorName: .empty,
                                       shareCount: row[totalShareCount] ?? 0))
        }
        return result
    }
    
    // MARK: - User statistics to be sent to the server
    
    func getShareCountByUniqueContentId() throws -> [ServerShareCountStat] {
        var result = [ServerShareCountStat]()
        
        let install_id = Expression<String>("installId")
        let content_id = Expression<String>("contentId")
        let content_type = Expression<Int>("contentType")
        let sent_to_server = Expression<Bool>("sentToServer")
        
        let contentCount = content_id.count
        for row in try db.prepare(userShareLog
                                      .select(install_id,content_id,content_type,contentCount)
                                      .where(sent_to_server == false)
                                      .group(content_id)
                                      .order(contentCount.desc)) {
            result.append(ServerShareCountStat(installId: row[install_id],
                                               contentId: row[content_id],
                                               contentType: row[content_type],
                                               shareCount: row[contentCount]))
        }
        return result
    }
    
    // MARK: - Audience statistics from the server
    
    func insert(audienceStat newAudienceStat: AudienceShareCountStat) throws {
        let insert = try audienceSharingStatistic.insert(newAudienceStat)
        try db.run(insert)
    }
    
    func getAudienceSharingStatCount() throws -> Int {
        try db.scalar(audienceSharingStatistic.count)
    }

}

extension LocalDatabase {

    static func databaseFilepath() -> String {
        let path = NSSearchPathForDirectoriesInDomains(
            .cachesDirectory, .userDomainMask, true
        ).first!
        return "\(path)/medo_db.sqlite3"
    }
    
    static func migrations() -> [Migration] {
        return [InitialMigration(), AddNetworkCallLogTable(), AddUserFolderTable()]
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

}
