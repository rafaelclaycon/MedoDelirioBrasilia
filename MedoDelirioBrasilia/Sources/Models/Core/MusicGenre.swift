//
//  MusicGenre.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 26/08/23.
//

import Foundation

struct MusicGenre: Hashable, Codable, Identifiable {

    let id: String
    let symbol: String
    let name: String
    let isHidden: Bool

    init(
        id: String,
        symbol: String,
        name: String,
        isHidden: Bool
    ) {
        self.id = id
        self.symbol = symbol
        self.name = name
        self.isHidden = isHidden
    }
}
