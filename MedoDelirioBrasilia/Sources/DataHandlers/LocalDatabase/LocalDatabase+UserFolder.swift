import Foundation

extension LocalDatabase {

    func insert(userFolder newFolder: UserFolder) throws {
        let insert = try userFolder.insert(newFolder)
        try db.run(insert)
    }
    
    func getAllUserFolders() throws -> [UserFolder] {
        var queriedFolders = [UserFolder]()

        for queriedFolder in try db.prepare(userFolder) {
            queriedFolders.append(try queriedFolder.decode())
        }
        return queriedFolders
    }

}
