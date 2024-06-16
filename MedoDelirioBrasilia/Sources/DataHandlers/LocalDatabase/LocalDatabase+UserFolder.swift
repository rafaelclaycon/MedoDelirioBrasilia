import Foundation
import SQLite

private typealias Expression = SQLite.Expression

extension LocalDatabase {

    func insert(userFolder newFolder: UserFolder) throws {
        var folder = newFolder
        folder.editingIdentifyingId = nil
        let insert = try userFolder.insert(folder)
        try db.run(insert)
    }
    
    func getFolder(withId folderId: String) throws -> UserFolder {
        var queriedFolders = [UserFolder]()
        
        let id = Expression<String>("id")
        let query = userFolder.filter(id == folderId)

        for queriedFolder in try db.prepare(query) {
            queriedFolders.append(try queriedFolder.decode())
        }
        if queriedFolders.count == 0 {
            throw LocalDatabaseError.folderNotFound
        } else if queriedFolders.count > 1 {
            throw LocalDatabaseError.internalError
        } else {
            return queriedFolders.first!
        }
    }
    
    func update(userFolder userFolderId: String, withNewSymbol newSymbol: String, newName: String, andNewBackgroundColor newBackgroundColor: String) throws {
        let id = Expression<String>("id")
        let symbol = Expression<String>("symbol")
        let name = Expression<String>("name")
        let background_color = Expression<String>("backgroundColor")
        
        let folder = userFolder.filter(id == userFolderId)
        let update = folder.update(symbol <- newSymbol, name <- newName, background_color <- newBackgroundColor)
        try db.run(update)
    }
    
    func getAllUserFolders() throws -> [UserFolder] {
        var queriedFolders = [UserFolder]()

        for queriedFolder in try db.prepare(userFolder) {
            queriedFolders.append(try queriedFolder.decode())
        }
        
        for i in 0..<queriedFolders.count {
            queriedFolders[i].editingIdentifyingId = UUID().uuidString
        }
        
        return queriedFolders
    }
    
    func insert(contentId: String, intoUserFolder userFolderId: String) throws {
        let folderContent = UserFolderContent(userFolderId: userFolderId, contentId: contentId, dateAdded: .now)
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
    
    func getAllContentsInsideUserFolder(withId userFolderId: String) throws -> [UserFolderContent] {
        var queriedContents = [UserFolderContent]()
        let user_folder_id = Expression<String>("userFolderId")
        
        for queriedContent in try db.prepare(userFolderContent.where(user_folder_id == userFolderId)) {
            queriedContents.append(try queriedContent.decode())
        }
        
        return queriedContents
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
    
    func hasAnyUserFolder() throws -> Bool {
        return try db.scalar(userFolder.count) > 0
    }
    
    func update(userSortPreference: Int, forFolderId userFolderId: String) throws {
        let id = Expression<String>("id")
        let user_sort_preference = Expression<Int?>("userSortPreference")
        
        let folder = userFolder.filter(id == userFolderId)
        let update = folder.update(user_sort_preference <- userSortPreference)
        try db.run(update)
    }

}
