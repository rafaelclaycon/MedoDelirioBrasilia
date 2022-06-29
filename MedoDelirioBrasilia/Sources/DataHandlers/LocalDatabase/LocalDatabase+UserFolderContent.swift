import Foundation
import SQLite

extension LocalDatabase {

    func contentExistsInsideUserFolder(withId folderId: String, contentId: String) throws -> Bool {
        let user_folder_id = Expression<String>("userFolderId")
        let content_id = Expression<String>("contentId")
        return try db.scalar(userFolderContent.filter(user_folder_id == folderId).filter(content_id == contentId).count) > 0
    }
    
    func deleteUserContentFromFolder(withId folderId: String, contentId: String) throws {
        let user_folder_id = Expression<String>("userFolderId")
        let content_id = Expression<String>("contentId")
        let specificFolderContent = userFolderContent.filter(user_folder_id == folderId).filter(content_id == contentId)
        if try db.run(specificFolderContent.delete()) == 0 {
            throw LocalDatabaseError.folderContentNotFound
        }
    }

}
