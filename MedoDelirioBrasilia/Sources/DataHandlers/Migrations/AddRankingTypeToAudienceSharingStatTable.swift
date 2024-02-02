import Foundation
import SQLiteMigrationManager
import SQLite

// swiftlint:disable identifier_name
struct AddRankingTypeToAudienceSharingStatTable: Migration {

    var version: Int64 = 2022_10_17_17_10_00

    private var audienceSharingStatistic = Table("audienceSharingStatistic")

    func migrateDatabase(_ db: Connection) throws {
        try createRankingTypeField(db)
    }

    private func createRankingTypeField(_ db: Connection) throws {
        let rankingType = Expression<Int?>("rankingType")
        try db.run(audienceSharingStatistic.addColumn(rankingType))
    }
}
// swiftlint:enable identifier_name
