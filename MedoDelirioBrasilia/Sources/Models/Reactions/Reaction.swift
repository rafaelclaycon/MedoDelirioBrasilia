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
    var type: ReactionType
    var attributionText: String?
    var attributionURL: URL?

    init(
        id: String,
        title: String,
        position: Int,
        image: String,
        lastUpdate: String,
        type: ReactionType,
        attributionText: String?,
        attributionURL: URL?
    ) {
        self.id = id
        self.title = title
        self.position = position
        self.image = image
        self.lastUpdate = lastUpdate
        self.type = type
        self.attributionText = attributionText
        self.attributionURL = attributionURL
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
        self.attributionText = nil
        self.attributionURL = nil
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
        self.attributionText = dto.attributionText
        if let url = dto.attributionURL {
            self.attributionURL = URL(string: url)
        } else {
            self.attributionURL = nil
        }
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
    let attributionText: String?
    let attributionURL: String?
}

extension ReactionDTO {

    var reaction: Reaction {
        Reaction(dto: self, type: .regular)
    }
}
