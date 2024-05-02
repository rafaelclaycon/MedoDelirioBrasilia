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
    let position: Int
    var image: String
    let titleSize: Int
    let lastUpdate: String

    init(
        id: String,
        title: String,
        position: Int,
        image: String,
        titleSize: Int,
        lastUpdate: String
    ) {
        self.id = id
        self.title = title
        self.position = position
        self.image = image
        self.titleSize = titleSize
        self.lastUpdate = lastUpdate
    }

    init(
        id: String = UUID().uuidString,
        title: String,
        position: Int = 0,
        image: String,
        titleSize: Int = 10
    ) {
        self.id = id
        self.title = title
        self.position = position
        self.image = image
        self.titleSize = titleSize
        self.lastUpdate = ""
    }
}
