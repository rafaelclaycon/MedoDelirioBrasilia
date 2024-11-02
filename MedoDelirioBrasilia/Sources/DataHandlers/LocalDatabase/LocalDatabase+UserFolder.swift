import Foundation
import SQLite

private typealias Expression = SQLite.Expression

extension LocalDatabase {

    func insert(_ newFolder: UserFolder) throws {
        try db.run(userFolder.insert(newFolder))
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
    
    func update(_ folder: UserFolder) throws {
        let id = Expression<String>("id")
        let symbol = Expression<String>("symbol")
        let name = Expression<String>("name")
        let background_color = Expression<String>("backgroundColor")
        let change_hash = Expression<String?>("changeHash")

        try db.run(
            userFolder
                .filter(id == folder.id)
                .update(
                    symbol <- folder.symbol,
                    name <- folder.name,
                    background_color <- folder.backgroundColor,
                    change_hash <- folder.changeHash
                )
        )
    }
    
    func allFolders() throws -> [UserFolder] {
        let creationDate = Expression<String>("creationDate")
        let sortedQuery = try db.prepare(userFolder.order(creationDate.asc))

        return try sortedQuery.map { queriedFolder in
            try queriedFolder.decode() as UserFolder
        }
    }
    
    func insert(contentId: String, intoUserFolder userFolderId: String) throws {
        let folderContent = UserFolderContent(userFolderId: userFolderId, contentId: contentId, dateAdded: .now)
        let insert = try userFolderContent.insert(folderContent)
        try db.run(insert)
    }
    
    func soundIdsInside(userFolder userFolderId: String) throws -> [String] {
        var queriedIds = [String]()
        let user_folder_id = Expression<String>("userFolderId")
        let content_id = Expression<String>("contentId")

        for row in try db.prepare(
            userFolderContent
                .select(content_id)
                .where(user_folder_id == userFolderId)
        ) {
            queriedIds.append(row[content_id])
        }
        return queriedIds
    }
    
    func contentsInside(userFolder userFolderId: String) throws -> [UserFolderContent] {
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
