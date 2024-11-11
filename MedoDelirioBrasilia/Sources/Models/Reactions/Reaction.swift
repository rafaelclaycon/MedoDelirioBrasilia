//
//  Reaction.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import Foundation

struct Reaction: Hashable, Codable, Identifiable {

    let id: String
    let title: String
    let position: Int
    let image: String
    var lastUpdate: String

    init(
        id: String,
        title: String,
        position: Int,
        image: String,
        lastUpdate: String
    ) {
        self.id = id
        self.title = title
        self.position = position
        self.image = image
        self.lastUpdate = lastUpdate
    }

    init(
        id: String = UUID().uuidString,
        title: String,
        position: Int = 0,
        image: String
    ) {
        self.id = id
        self.title = title
        self.position = position
        self.image = image
        self.lastUpdate = ""
    }
}
