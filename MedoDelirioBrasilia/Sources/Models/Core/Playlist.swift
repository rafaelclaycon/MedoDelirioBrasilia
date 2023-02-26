//
//  Playlist.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 24/02/23.
//

import Foundation

struct Playlist: Hashable, Codable, Identifiable {

    var id: String
    var name: String
    var creationDate: Date
    
    init(id: String = UUID().uuidString,
         name: String,
         creationDate: Date = .now) {
        self.id = id
        self.name = name
        self.creationDate = creationDate
    }

}
