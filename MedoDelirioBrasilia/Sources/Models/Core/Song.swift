//
//  Song.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 19/05/22.
//

import AVFoundation

struct Song: Hashable, Codable, Identifiable {

    var id: String
    var title: String
    var description: String
    var genre: MusicGenre
    var duration: Double
    var filename: String
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

extension Song {

    func getDuration() -> Double {
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: self.filename, ofType: nil)!)
        let asset = AVURLAsset(url: url)
        return asset.duration.seconds
    }

}
