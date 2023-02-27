//
//  LocalDatabase+PlaylistContent.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 26/02/23.
//

import Foundation
import SQLite

extension LocalDatabase {
    
    func contentExistsInsidePlaylist(withId playlistId: String, contentId: String) throws -> Bool {
        let playlist_id = Expression<String>("playlistId")
        let content_id = Expression<String>("contentId")
        return try db.scalar(playlistContent.filter(playlist_id == playlistId).filter(content_id == contentId).count) > 0
    }
    
    func deleteContentFromPlaylist(withId playlistId: String, contentId: String) throws {
        let playlist_id = Expression<String>("playlistId")
        let content_id = Expression<String>("contentId")
        let specificPlaylistContent = playlistContent.filter(playlist_id == playlistId).filter(content_id == contentId)
        if try db.run(specificPlaylistContent.delete()) == 0 {
            throw LocalDatabaseError.folderContentNotFound
        }
    }
    
}
