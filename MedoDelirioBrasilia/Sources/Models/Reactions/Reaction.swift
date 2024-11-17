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
    let type: ReactionType

    init(
        id: String,
        title: String,
        position: Int,
        image: String,
        lastUpdate: String,
        type: ReactionType
    ) {
        self.id = id
        self.title = title
        self.position = position
        self.image = image
        self.lastUpdate = lastUpdate
        self.type = type
    }

    init(
        id: String = UUID().uuidString,
        title: String,
        position: Int = 0,
        image: String,
        type: ReactionType = .regular
    ) {
        self.id = id
        self.title = title
        self.position = position
        self.image = image
        self.lastUpdate = ""
        self.type = type
    }

    init(
        dto: ReactionDTO,
        type: ReactionType
    ) {
        self.id = dto.id
        self.title = dto.title
        self.position = dto.position
        self.image = dto.image
        self.lastUpdate = dto.lastUpdate
        self.type = type
    }
}

enum ReactionType: Int, Codable {

    case regular, pinnedExisting, pinnedRemoved
}

struct ReactionDTO: Hashable, Codable, Identifiable {

    let id: String
    let title: String
    let position: Int
    let image: String
    let lastUpdate: String
}
