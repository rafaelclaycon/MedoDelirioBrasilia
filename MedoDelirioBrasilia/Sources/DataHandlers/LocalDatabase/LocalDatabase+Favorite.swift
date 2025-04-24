import Foundation
import SQLite

private typealias Expression = SQLite.Expression

extension LocalDatabase {

    func favoriteCount() throws -> Int {
        try db.scalar(favorite.count)
    }
    
    func insert(favorite newFavorite: Favorite) throws {
        let insert = try favorite.insert(newFavorite)
        try db.run(insert)
    }
    
    func favorites() throws -> [Favorite] {
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
    }

    func isFavorite(contentId: String) throws -> Bool {
        let id = Expression<String>("contentId")
        let query = soundTable.filter(id == contentId)
        let count = try db.scalar(query.count)
        return count > 0
    }
}
