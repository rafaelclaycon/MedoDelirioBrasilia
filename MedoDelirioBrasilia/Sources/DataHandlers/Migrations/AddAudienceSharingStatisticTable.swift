import Foundation
import SQLiteMigrationManager
import SQLite

struct AddAudienceSharingStatisticTable: Migration {

    var version: Int64 = 2022_10_12_15_45_00
    
    private var audienceSharingStatistic = Table("audienceSharingStatistic")
    
    func migrateDatabase(_ db: Connection) throws {
        try createAudienceSharingStatisticTable(db)
    }
    
    private func createAudienceSharingStatisticTable(_ db: Connection) throws {
        let content_id = Expression<String>("contentId")
        let content_type = Expression<Int>("contentType")
        let share_count = Expression<Int>("shareCount")

        try db.run(audienceSharingStatistic.create(ifNotExists: true) { t in
            t.column(content_id)
            t.column(content_type)
            t.column(share_count)
        })
    }

}
