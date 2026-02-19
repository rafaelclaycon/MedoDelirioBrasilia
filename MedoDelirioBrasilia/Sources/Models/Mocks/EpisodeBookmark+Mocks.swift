//
//  EpisodeBookmark+Mocks.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 18/02/26.
//

import Foundation

extension EpisodeBookmark {

    static let mockIntro = EpisodeBookmark(
        id: "bookmark-1",
        episodeId: "mock-recent",
        timestamp: 45,
        title: "Introdução do tema",
        note: "O apresentador contextualiza o cenário político da semana.",
        createdAt: Date().addingTimeInterval(-3600)
    )

    static let mockHighlight = EpisodeBookmark(
        id: "bookmark-2",
        episodeId: "mock-recent",
        timestamp: 1230,
        title: "Declaração polêmica",
        note: nil,
        createdAt: Date().addingTimeInterval(-1800)
    )

    static let mockUntitled = EpisodeBookmark(
        id: "bookmark-3",
        episodeId: "mock-recent",
        timestamp: 2540,
        title: nil,
        note: nil,
        createdAt: Date().addingTimeInterval(-600)
    )

    static let mocks: [EpisodeBookmark] = [
        .mockIntro,
        .mockHighlight,
        .mockUntitled,
    ]
}
