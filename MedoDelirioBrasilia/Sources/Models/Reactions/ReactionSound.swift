//
//  ReactionSound.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 03/05/24.
//

import Foundation

struct ReactionSound: Identifiable, Codable {

    let id: String
    let soundId: String
    let dateAdded: String
    let position: Int
    
    enum CodingKeys: String, CodingKey {
        case id, soundId, dateAdded, position
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? "default-id"
        soundId = try container.decode(String.self, forKey: .soundId)
        dateAdded = try container.decode(String.self, forKey: .dateAdded)
        position = try container.decode(Int.self, forKey: .position)
    }
    
    init(
        id: String?,
        soundId: String,
        dateAdded: String,
        position: Int
    ) {
        self.id = soundId
        self.soundId = soundId
        self.dateAdded = dateAdded
        self.position = position
    }
    
    init(
        soundId: String,
        dateAdded: String,
        position: Int
    ) {
        self.id = soundId
        self.soundId = soundId
        self.dateAdded = dateAdded
        self.position = position
    }
}