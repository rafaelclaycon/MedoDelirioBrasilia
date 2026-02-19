//
//  EpisodeFilterOption.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 18/02/26.
//

import Foundation

enum EpisodeFilterOption: CaseIterable, FilterOption {

    case all, favorites, notPlayed, played, bookmarked

    var id: String { displayName }

    var displayName: String {
        switch self {
        case .all: "Todos"
        case .notPlayed: "Não Reproduzidos"
        case .favorites: "Favoritos"
        case .played: "Finalizados"
        case .bookmarked: "Com Marcadores"
        }
    }
}
