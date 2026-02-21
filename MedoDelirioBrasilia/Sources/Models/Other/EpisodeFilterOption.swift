//
//  EpisodeFilterOption.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 18/02/26.
//

import Foundation

enum EpisodeFilterOption: CaseIterable, FilterOption {

    case all, favorites, bookmarked

    var id: String { displayName }

    var displayName: String {
        switch self {
        case .all: "Todos"
        case .favorites: "Favoritos"
        case .bookmarked: "Com Marcadores"
        }
    }
}
