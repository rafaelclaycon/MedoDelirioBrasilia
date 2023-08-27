//
//  Author.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 20/05/22.
//

import Foundation

struct Author: Hashable, Codable, Identifiable {

    let id: String
    let name: String
    let photo: String?
    let description: String?
    var soundCount: Int?

    init(id: String, name: String, photo: String? = nil, description: String? = nil, soundCount: Int? = nil) {
        self.id = id
        self.name = name
        self.photo = photo
        self.description = description
        self.soundCount = soundCount
    }
}
