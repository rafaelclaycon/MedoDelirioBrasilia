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
    
    func insert(contentId: String, intoUserFolder userFolderId: String) throws {
        let folderContent = UserFolderContent(userFolderId: userFolderId, contentId: contentId)
        let insert = try userFolderContent.insert(folderContent)
        try db.run(insert)
    }

}
