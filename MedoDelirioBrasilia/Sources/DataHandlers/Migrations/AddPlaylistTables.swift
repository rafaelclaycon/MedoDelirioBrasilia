//
//  AddPlaylistTables.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 24/02/23.
//

import Foundation
import SQLiteMigrationManager
import SQLite

struct AddPlaylistTables: Migration {

    var version: Int64 = 2023_02_24_21_47_00
    
    private var playlist = Table("playlist")
    private var playlistContent = Table("playlistContent")
    
    func migrateDatabase(_ db: Connection) throws {
        try createPlaylistTable(db)
        try createPlaylistContentTable(db)
    }
    
    private func createPlaylistTable(_ db: Connection) throws {
        let id = Expression<String>("id")
        let name = Expression<String>("name")
        let creation_date = Expression<Date>("creationDate")
        
        try db.run(playlist.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(name)
            t.column(creation_date)
        })
    }
    
    private func createPlaylistContentTable(_ db: Connection) throws {
        let playlist_id = Expression<String>("playlistId")
        let content_id = Expression<String>("contentId")
        let order = Expression<Int>("order")
        let date_added = Expression<Date>("dateAdded")
        
        try db.run(playlistContent.create(ifNotExists: true) { t in
            t.column(playlist_id)
            t.column(content_id)
            t.column(order)
            t.column(date_added)
        })
    }

}
