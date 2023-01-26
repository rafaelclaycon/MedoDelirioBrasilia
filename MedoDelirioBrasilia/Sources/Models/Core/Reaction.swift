//
//  Reaction.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import Foundation

struct Reaction: Hashable, Codable, Identifiable {

    var id: String
    var title: String
    var imageUrl: String
    var contentFile: String
    
    init(id: String = UUID().uuidString,
         title: String,
         imageUrl: String,
         contentFile: String) {
        self.id = id
        self.title = title
        self.imageUrl = imageUrl
        self.contentFile = contentFile
    }

}
