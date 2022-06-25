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
    
    func deleteUserFolder(withId folderId: String) throws {
        let folder_id_on_folder_content_table = Expression<String>("userFolderId")
        let allFolderContent = userFolderContent.filter(folder_id_on_folder_content_table == folderId)
        try db.run(allFolderContent.delete())
        
        let folder_id_on_folder_table = Expression<String>("id")
        let folder = userFolder.filter(folder_id_on_folder_table == folderId)
        if try db.run(folder.delete()) == 0 {
            throw LocalDatabaseError.folderNotFound
        }
    }

}
