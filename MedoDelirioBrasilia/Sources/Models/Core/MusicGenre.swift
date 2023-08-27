//
//  MusicGenre.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 26/08/23.
//

import Foundation

struct MusicGenre: Hashable, Codable, Identifiable {

    let id: String
    let name: String
    let isHidden: Bool

    init(
        id: String,
        name: String,
        isHidden: Bool
    ) {
        self.id = id
        self.name = name
        self.isHidden = isHidden
    }
}
