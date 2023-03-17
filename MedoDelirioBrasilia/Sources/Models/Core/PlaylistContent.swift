//
//  PlaylistContent.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 26/02/23.
//

import Foundation

struct PlaylistContent: Hashable, Codable {

    var playlistId: String
    var contentId: String
    var order: Int
    var dateAdded: Date
    var sound: Sound?
    
    init(playlistId: String,
         contentId: String,
         order: Int,
         dateAdded: Date = .now,
         sound: Sound? = nil) {
        self.playlistId = playlistId
        self.contentId = contentId
        self.order = order
        self.dateAdded = dateAdded
        self.sound = sound
    }
    
    init(content: PlaylistContent,
         sound: Sound?) {
        self.playlistId = content.playlistId
        self.contentId = content.contentId
        self.order = content.order
        self.dateAdded = content.dateAdded
        self.sound = sound
    }

}
