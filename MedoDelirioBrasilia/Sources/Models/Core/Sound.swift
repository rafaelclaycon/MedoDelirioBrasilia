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
    let isOffensive: Bool
    let isNew: Bool?
    
    init(id: String = UUID().uuidString,
         title: String,
         authorId: String = UUID().uuidString,
         description: String = "",
         filename: String = "",
         dateAdded: Date? = Date(),
         isOffensive: Bool = false,
         isNew: Bool?) {
        self.id = id
        self.title = title
        self.authorId = authorId
        self.description = description
        self.filename = filename
        self.dateAdded = dateAdded
        self.isOffensive = isOffensive
        self.isNew = isNew
    }

}
