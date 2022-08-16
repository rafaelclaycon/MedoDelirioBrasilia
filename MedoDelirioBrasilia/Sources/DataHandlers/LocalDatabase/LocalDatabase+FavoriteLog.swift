import Foundation
import SQLite

extension LocalDatabase {

    func getFavoriteLogCount() throws -> Int {
        try db.scalar(favoriteLog.count)
    }
    
    func insert(favoriteLog newLog: FavoriteLog) throws {
        let insert = try favoriteLog.insert(newLog)
        try db.run(insert)
    }
    
    func getAllFavoriteLogs() throws -> [FavoriteLog] {
        var queriedItems = [FavoriteLog]()

        for queriedItem in try db.prepare(favoriteLog) {
            queriedItems.append(try queriedItem.decode())
        }
        return queriedItems
    }
    
    func deleteAllFavoriteLogs() throws {
        try db.run(favoriteLog.delete())
    }

}
