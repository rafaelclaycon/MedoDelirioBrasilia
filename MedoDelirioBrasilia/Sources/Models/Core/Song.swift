//
//  Song.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 19/05/22.
//

import Foundation

struct Song: Hashable, Codable, Identifiable {

    let id: String
    let title: String
    let description: String
    let genre: String
    let duration: Double
    let filename: String
    var dateAdded: Date?
    let isOffensive: Bool

    init(id: String = UUID().uuidString,
         title: String,
         description: String = "",
         genre: String,
         duration: Double = 0,
         filename: String = "",
         dateAdded: Date = Date(),
         isOffensive: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.genre = genre
        self.duration = duration
        self.filename = filename
        self.dateAdded = dateAdded
        self.isOffensive = isOffensive
    }
}
