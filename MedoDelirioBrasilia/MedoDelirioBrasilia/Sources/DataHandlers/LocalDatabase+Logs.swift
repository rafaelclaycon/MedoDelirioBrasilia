import Foundation

extension LocalDatabase {

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
    
    // MARK: - Network Call Log
    
    func getNetworkCallLogCount() throws -> Int {
        try db.scalar(networkCallLog.count)
    }
    
    func insert(networkCallLog newLog: NetworkCallLog) throws {
        let insert = try networkCallLog.insert(newLog)
        try db.run(insert)
    }
    
    func getAllNetworkCallLogs() throws -> [NetworkCallLog] {
        var queriedItems = [NetworkCallLog]()

        for queriedItem in try db.prepare(networkCallLog) {
            queriedItems.append(try queriedItem.decode())
        }
        return queriedItems
    }
    
    func deleteAllNetworkCallLogs() throws {
        try db.run(networkCallLog.delete())
    }

}
