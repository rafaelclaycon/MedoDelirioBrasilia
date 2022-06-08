import Foundation
import SQLite
import SQLiteMigrationManager

class LocalDatabase {

    private var db: Connection
    
    private var favorite = Table("favorite")
    private var userShareLog = Table("userShareLog")
    private var audienceSharingStatistic = Table("audienceSharingStatistic")

    // MARK: - Init

    init() {
        let path = NSSearchPathForDirectoriesInDomains(
            .cachesDirectory, .userDomainMask, true
        ).first!

        do {
            db = try Connection("\(path)/medo_db.sqlite3")
            try createFavoriteTable()
            /*try createUserShareLogTable()
            try createAudienceSharingStatisticTable()*/
        } catch {
            fatalError(error.localizedDescription)
        }
        
        /*let manager = SQLiteMigrationManager(db: self.db)
        
        do {
            if !manager.hasMigrationsTable() {
                try manager.createMigrationsTable()
            }
        } catch {
            fatalError(error.localizedDescription)
        }*/
    }

    private func createFavoriteTable() throws {
        let content_id = Expression<String>("contentId")
        let date_added = Expression<Date>("dateAdded")

        try db.run(favorite.create(ifNotExists: true) { t in
            t.column(content_id, primaryKey: true)
            t.column(date_added)
        })
    }
    
    private func createUserShareLogTable() throws {
        let install_id = Expression<String>("installId")
        let content_id = Expression<String>("contentId")
        let content_type = Expression<Int>("contentType")
        let date_time = Expression<Date>("dateTime")
        let destination = Expression<Int>("destination")
        let destination_bundle_id = Expression<String>("destinationBundleId")
        let sent_to_server = Expression<Bool>("sentToServer")

        try db.run(userShareLog.create(ifNotExists: true) { t in
            t.column(install_id)
            t.column(content_id)
            t.column(content_type)
            t.column(date_time)
            t.column(destination)
            t.column(destination_bundle_id)
            t.column(sent_to_server)
        })
    }
    
    private func createAudienceSharingStatisticTable() throws {
        let content_id = Expression<String>("contentId")
        let content_type = Expression<Int>("contentType")
        let share_count = Expression<Int>("shareCount")

        try db.run(audienceSharingStatistic.create(ifNotExists: true) { t in
            t.column(content_id)
            t.column(content_type)
            t.column(share_count)
        })
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
    
    // MARK: - User Share Log
    
    func getUserShareLogCount() throws -> Int {
        try db.scalar(userShareLog.count)
    }
    
    func insert(userShareLog newLog: UserShareLog) throws {
        let insert = try userShareLog.insert(newLog)
        try db.run(insert)
    }
    
    func getAllUserShareLogs() throws -> [UserShareLog] {
        var queriedItems = [UserShareLog]()

        for queriedItem in try db.prepare(userShareLog) {
            queriedItems.append(try queriedItem.decode())
        }
        return queriedItems
    }
    
    func deleteAllUserShareLogs() throws {
        try db.run(userShareLog.delete())
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

enum LocalDatabaseError: Error {

    case favoriteNotFound

}
