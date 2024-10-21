//
//  ContentSortOption.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 26/05/22.
//

import Foundation

enum SoundSortOption: Int {
    case titleAscending, authorNameAscending, dateAddedDescending, shortestFirst, longestFirst, longestTitleFirst, shortestTitleFirst
}

enum SongSortOption: Int {
    case titleAscending, dateAddedDescending, durationDescending, durationAscending
}

enum AuthorSortOption: Int {
    case nameAscending, soundCountDescending, soundCountAscending
}

enum FolderSoundSortOption: Int {
    case titleAscending, authorNameAscending, dateAddedDescending
}

enum ReactionSoundSortOption: Int, CaseIterable, CustomStringConvertible {
    case `default`, /*appMostPopularDescending, reactionMostPopularDescending,*/ dateAddedDescending, dateAddedAscending

    var description: String {
        switch self {
        case .default:
            "Padrão"
//        case .appMostPopularDescending:
//            "Mais Populares do App no Topo"
//        case .reactionMostPopularDescending:
//            "Mais Populares Dessa Reação no Topo"
        case .dateAddedDescending:
            "Mais Recentes no Topo"
        case .dateAddedAscending:
            "Mais Antigos no Topo"
        }
    }
}
