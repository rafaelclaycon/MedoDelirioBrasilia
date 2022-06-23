import Foundation
import SQLite

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
    
    func getAllSoundIdsInsideUserFolder(withId userFolderId: String) throws -> [String] {
        var queriedIds = [String]()
        let user_folder_id = Expression<String>("userFolderId")
        let content_id = Expression<String>("contentId")

        for row in try db.prepare(userFolderContent
                                      .select(content_id)
                                      .where(user_folder_id == userFolderId)) {
            queriedIds.append(row[content_id])
        }
        return queriedIds
    }

}
