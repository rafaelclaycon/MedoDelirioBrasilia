//
//  Song.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 19/05/22.
//

import AVFoundation

struct Song: Hashable, Codable, Identifiable {

    let id: String
    let title: String
    let description: String
    let genre: MusicGenre
    let duration: Double
    let filename: String
    var dateAdded: Date?
    let isOffensive: Bool
    let isNew: Bool?
    
    init(id: String = UUID().uuidString,
         title: String,
         description: String = "",
         genre: MusicGenre = .undefined,
         duration: Double = 0,
         filename: String = "",
         dateAdded: Date = Date(),
         isOffensive: Bool = false,
         isNew: Bool?) {
        self.id = id
        self.title = title
        self.description = description
        self.genre = genre
        self.duration = duration
        self.filename = filename
        self.dateAdded = dateAdded
        self.isOffensive = isOffensive
        self.isNew = isNew
    }

}
