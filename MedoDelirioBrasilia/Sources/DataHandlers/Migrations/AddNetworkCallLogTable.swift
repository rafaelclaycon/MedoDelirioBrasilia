import Foundation
import SQLiteMigrationManager
import SQLite

struct AddNetworkCallLogTable: Migration {

    var version: Int64 = 2022_06_13_20_13_00
    
    private var networkCallLog = Table("networkCallLog")
    
    func migrateDatabase(_ db: Connection) throws {
        try createNetworkCallLogTable(db)
    }
    
    private func createNetworkCallLogTable(_ db: Connection) throws {
        let id = Expression<String>("id")
        let call_type = Expression<Int>("callType")
        let request_body = Expression<String>("requestBody")
        let response = Expression<String>("response")
        let date_time = Expression<Date>("dateTime")
        let was_successful = Expression<Bool>("wasSuccessful")

        try db.run(networkCallLog.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(call_type)
            t.column(request_body)
            t.column(response)
            t.column(date_time)
            t.column(was_successful)
        })
    }

}
