import Foundation
import SQLiteMigrationManager
import SQLite

struct InitialMigration: Migration {

    var version: Int64 = 2022_06_10_17_05_00
    
    private var favorite = Table("favorite")
    private var userShareLog = Table("userShareLog")
    //private var audienceSharingStatistic = Table("audienceSharingStatistic")
    
    func migrateDatabase(_ db: Connection) throws {
        try createFavoriteTable(db)
        try createUserShareLogTable(db)
        //try createAudienceSharingStatisticTable(db)
    }
    
    private func createFavoriteTable(_ db: Connection) throws {
        let content_id = Expression<String>("contentId")
        let date_added = Expression<Date>("dateAdded")

        try db.run(favorite.create(ifNotExists: true) { t in
            t.column(content_id, primaryKey: true)
            t.column(date_added)
        })
    }
    
    private func createUserShareLogTable(_ db: Connection) throws {
        let id = Expression<String>("id")
        let install_id = Expression<String>("installId")
        let content_id = Expression<String>("contentId")
        let content_type = Expression<Int>("contentType")
        let date_time = Expression<Date>("dateTime")
        let destination = Expression<Int>("destination")
        let destination_bundle_id = Expression<String>("destinationBundleId")
        let sent_to_server = Expression<Bool>("sentToServer")

        try db.run(userShareLog.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(install_id)
            t.column(content_id)
            t.column(content_type)
            t.column(date_time)
            t.column(destination)
            t.column(destination_bundle_id)
            t.column(sent_to_server)
        })
    }
    
//    private func createAudienceSharingStatisticTable(_ db: Connection) throws {
//        let content_id = Expression<String>("contentId")
//        let content_type = Expression<Int>("contentType")
//        let share_count = Expression<Int>("shareCount")
//
//        try db.run(audienceSharingStatistic.create(ifNotExists: true) { t in
//            t.column(content_id)
//            t.column(content_type)
//            t.column(share_count)
//        })
//    }

}
