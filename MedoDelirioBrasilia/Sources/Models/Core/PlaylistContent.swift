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
    
    init(playlistId: String,
         contentId: String,
         order: Int,
         dateAdded: Date = .now) {
        self.playlistId = playlistId
        self.contentId = contentId
        self.order = order
        self.dateAdded = dateAdded
    }

}
