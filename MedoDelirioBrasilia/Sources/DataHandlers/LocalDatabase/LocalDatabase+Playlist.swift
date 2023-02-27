//
//  LocalDatabase+Playlist.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 24/02/23.
//

import Foundation
import SQLite

extension LocalDatabase {

    func insert(playlist newPlaylist: Playlist) throws {
        let insert = try playlist.insert(newPlaylist)
        try db.run(insert)
    }
    
    func getPlaylist(withId playlistId: String) throws -> Playlist {
        var queriedPlaylists = [Playlist]()
        
        let id = Expression<String>("id")
        let query = userFolder.filter(id == playlistId)

        for queriedPlaylist in try db.prepare(query) {
            queriedPlaylists.append(try queriedPlaylist.decode())
        }
        if queriedPlaylists.count == 0 {
            throw LocalDatabaseError.folderNotFound
        } else if queriedPlaylists.count > 1 {
            throw LocalDatabaseError.internalError
        } else {
            return queriedPlaylists.first!
        }
    }
    
//    func update(userFolder userFolderId: String, withNewSymbol newSymbol: String, newName: String, andNewBackgroundColor newBackgroundColor: String) throws {
//        let id = Expression<String>("id")
//        let symbol = Expression<String>("symbol")
//        let name = Expression<String>("name")
//        let background_color = Expression<String>("backgroundColor")
//
//        let folder = userFolder.filter(id == userFolderId)
//        let update = folder.update(symbol <- newSymbol, name <- newName, background_color <- newBackgroundColor)
//        try db.run(update)
//    }
    
    func getAllPlaylists() throws -> [Playlist] {
        var queriedPlaylists = [Playlist]()

        for queriedPlaylist in try db.prepare(playlist) {
            queriedPlaylists.append(try queriedPlaylist.decode())
        }

//        for i in 0..<queriedFolders.count {
//            queriedFolders[i].editingIdentifyingId = UUID().uuidString
//        }

        return queriedPlaylists
    }
    
    func insert(contentId: String, intoPlaylist playlistId: String) throws {
        let order_on_table = Expression<Int>("order")
        let playlist_id = Expression<String>("playlistId")
        var newOrder = 0
        if let maxOrder = try db.scalar(playlistContent.select(order_on_table.max).where(playlist_id == playlistId)) {
            newOrder = maxOrder + 1
        }
        
        let content = PlaylistContent(playlistId: playlistId, contentId: contentId, order: newOrder, dateAdded: .now)
        let insert = try playlistContent.insert(content)
        try db.run(insert)
    }
    
//    func getAllSoundIdsInsideUserFolder(withId userFolderId: String) throws -> [String] {
//        var queriedIds = [String]()
//        let user_folder_id = Expression<String>("userFolderId")
//        let content_id = Expression<String>("contentId")
//
//        for row in try db.prepare(userFolderContent
//                                      .select(content_id)
//                                      .where(user_folder_id == userFolderId)) {
//            queriedIds.append(row[content_id])
//        }
//        return queriedIds
//    }
    
    func getAllContentsInsidePlaylist(withId playlistId: String) throws -> [PlaylistContent] {
        var queriedContents = [PlaylistContent]()
        let playlist_id = Expression<String>("playlistId")
        
        for queriedContent in try db.prepare(playlistContent.where(playlist_id == playlistId)) {
            queriedContents.append(try queriedContent.decode())
        }
        
        return queriedContents
    }
    
    func deletePlaylist(withId playlistId: String) throws {
        let playlist_id_on_playlist_content_table = Expression<String>("playlistId")
        let allPlaylistContent = playlistContent.filter(playlist_id_on_playlist_content_table == playlistId)
        try db.run(allPlaylistContent.delete())

        let playlist_id_on_playlist_table = Expression<String>("id")
        let folder = playlist.filter(playlist_id_on_playlist_table == playlistId)
        if try db.run(folder.delete()) == 0 {
            throw LocalDatabaseError.folderNotFound
        }
    }
    
//    func hasAnyUserFolder() throws -> Bool {
//        return try db.scalar(userFolder.count) > 0
//    }

}
