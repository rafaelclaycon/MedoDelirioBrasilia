import Foundation
import SQLiteMigrationManager
import SQLite

// swiftlint:disable identifier_name
struct AddNetworkCallLogTable: Migration {

    var version: Int64 = 2022_06_13_20_13_00

    private var networkCallLog = Table("networkCallLog")

    func migrateDatabase(_ db: Connection) throws {
        try createNetworkCallLogTable(db)
    }

    private func createNetworkCallLogTable(_ db: Connection) throws {
        let id = Expression<String>("id")
        let callType = Expression<Int>("callType")
        let requestBody = Expression<String>("requestBody")
        let response = Expression<String>("response")
        let dateTime = Expression<Date>("dateTime")
        let wasSuccessful = Expression<Bool>("wasSuccessful")

        try db.run(networkCallLog.create(ifNotExists: true) { table in
            table.column(id, primaryKey: true)
            table.column(callType)
            table.column(requestBody)
            table.column(response)
            table.column(dateTime)
            table.column(wasSuccessful)
        })
    }
}
// swiftlint:enable identifier_name
