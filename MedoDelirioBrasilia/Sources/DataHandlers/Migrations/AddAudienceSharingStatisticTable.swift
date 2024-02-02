import Foundation
import SQLiteMigrationManager
import SQLite

// swiftlint:disable identifier_name
struct AddAudienceSharingStatisticTable: Migration {

    var version: Int64 = 2022_10_12_15_45_00

    private var audienceSharingStatistic = Table("audienceSharingStatistic")

    func migrateDatabase(_ db: Connection) throws {
        try createAudienceSharingStatisticTable(db)
    }

    private func createAudienceSharingStatisticTable(_ db: Connection) throws {
        let contentId = Expression<String>("contentId")
        let contentType = Expression<Int>("contentType")
        let shareCount = Expression<Int>("shareCount")

        try db.run(audienceSharingStatistic.create(ifNotExists: true) { table in
            table.column(contentId)
            table.column(contentType)
            table.column(shareCount)
        })
    }
}
// swiftlint:enable identifier_name
