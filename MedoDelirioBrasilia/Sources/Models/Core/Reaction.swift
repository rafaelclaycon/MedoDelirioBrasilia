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
    var imageURL: String
    
    init(
        id: String = UUID().uuidString,
        title: String,
        imageURL: String
    ) {
        self.id = id
        self.title = title
        self.imageURL = imageURL
    }
}
