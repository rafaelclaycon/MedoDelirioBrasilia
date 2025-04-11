//
//  TopSelectorOption.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 29/03/25.
//

import Foundation

enum TopSelectorOption: CaseIterable, Identifiable {

    case all, favorites, songs, folders, authors

    var id: String {
        displayName
    }

    var displayName: String {
        switch self {
        case .all:
            "Tudo"
        case .favorites:
            "Favoritos"
        case .songs:
            "Músicas"
        case .folders:
            "Pastas"
        case .authors:
            "Autores"
        }
    }
}
