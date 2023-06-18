//
//  Sound.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 19/05/22.
//

import Foundation

struct Sound: Hashable, Codable, Identifiable {

    var id: String
    var title: String
    var authorId: String
    var authorName: String?
    var description: String
    var filename: String
    var dateAdded: Date?
    let duration: Double
    let isOffensive: Bool
    
    init(id: String = UUID().uuidString,
         title: String,
         authorId: String = UUID().uuidString,
         authorName: String? = nil,
         description: String = "",
         filename: String = "",
         dateAdded: Date? = Date(),
         duration: Double = 0,
         isOffensive: Bool = false
    ) {
        self.id = id
        self.title = title
        self.authorId = authorId
        self.authorName = authorName
        self.description = description
        self.filename = filename
        self.dateAdded = dateAdded
        self.duration = duration
        self.isOffensive = isOffensive
    }
}
