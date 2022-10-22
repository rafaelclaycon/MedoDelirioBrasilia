//
//  Favorite.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 24/05/22.
//

import Foundation

struct Favorite: Hashable, Codable {

    var contentId: String
    var dateAdded: Date
    
    init(contentId: String,
         dateAdded: Date = Date()) {
        self.contentId = contentId
        self.dateAdded = dateAdded
    }

}
