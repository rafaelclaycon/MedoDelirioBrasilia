//import Foundation
//import SQLiteMigrationManager
//import SQLite
//
//struct AddFavoriteLogTable: Migration {
//
//    var version: Int64 = 2022_08_16_17_53_00
//    
//    private var favoriteLog = Table("favoriteLog")
//    
//    func migrateDatabase(_ db: Connection) throws {
//        try createFavoriteLogTable(db)
//    }
//    
//    private func createFavoriteLogTable(_ db: Connection) throws {
//        let id = Expression<String>("id")
//        let favorite_count = Expression<Int>("favoriteCount")
//        let date_time = Expression<Date>("dateTime")
//        let app_version = Expression<String>("appVersion")
//        let device_model = Expression<String>("deviceModel")
//        let system_version = Expression<String>("systemVersion")
//        let call_moment = Expression<String>("callMoment")
//        let needs_migration = Expression<Bool>("needsMigration")
//        let install_id = Expression<String>("installId")
//        
//        try db.run(favoriteLog.create(ifNotExists: true) { t in
//            t.column(id, primaryKey: true)
//            t.column(favorite_count)
//            t.column(date_time)
//            t.column(app_version)
//            t.column(device_model)
//            t.column(system_version)
//            t.column(call_moment)
//            t.column(needs_migration)
//            t.column(install_id)
//        })
//    }
//
//}
