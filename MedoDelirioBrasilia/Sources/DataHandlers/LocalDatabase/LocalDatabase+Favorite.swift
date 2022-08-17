import Foundation
import SQLite

extension LocalDatabase {

    func getFavoriteCount() throws -> Int {
        try db.scalar(favorite.count)
    }
    
    func insert(favorite newFavorite: Favorite) throws {
        let insert = try favorite.insert(newFavorite)
        try db.run(insert)
        
        if let favoriteCount = try? getFavoriteCount() {
            Logger.logFavorites(favoriteCount: favoriteCount, callMoment: "insert(favorite)", needsMigration: false)
        } else {
            Logger.logFavorites(favoriteCount: 0, callMoment: "insert(favorite) - getFavoriteCount failed", needsMigration: false)
        }
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
        
        if let favoriteCount = try? getFavoriteCount() {
            Logger.logFavorites(favoriteCount: favoriteCount, callMoment: "deleteFavorite(withId)", needsMigration: false)
        } else {
            Logger.logFavorites(favoriteCount: 0, callMoment: "deleteFavorite(withId) - getFavoriteCount failed", needsMigration: false)
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

}
