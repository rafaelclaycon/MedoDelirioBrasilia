//
//  PodcastEpisode+Mocks.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 18/02/26.
//

import Foundation

extension PodcastEpisode {

    static let mockRecent = PodcastEpisode(
        id: "mock-recent",
        title: "O Governo Perdeu o Controle da Narrativa",
        pubDate: Date().addingTimeInterval(-3600 * 2),
        audioURL: URL(string: "https://example.com/ep1.mp3")!,
        description: "<b>Neste episódio</b>, discutimos como o governo perdeu a narrativa nas redes sociais e o impacto disso na opinião pública.<br />Com participação especial de especialistas em comunicação política.",
        imageURL: nil,
        duration: 3945,
        explicit: false
    )

    static let mockYesterday = PodcastEpisode(
        id: "mock-yesterday",
        title: "Brasília em Chamas: A Crise dos Três Poderes",
        pubDate: Date().addingTimeInterval(-3600 * 26),
        audioURL: URL(string: "https://example.com/ep2.mp3")!,
        description: "Uma análise completa dos embates entre Executivo, Legislativo e Judiciário que marcaram a semana. O que esperar dos próximos capítulos dessa novela política?",
        imageURL: nil,
        duration: 5220,
        explicit: false
    )

    static let mockLastWeek = PodcastEpisode(
        id: "mock-last-week",
        title: "Economia: O Real Derreteu ou Estamos Exagerando?",
        pubDate: Date().addingTimeInterval(-3600 * 24 * 5),
        audioURL: URL(string: "https://example.com/ep3.mp3")!,
        description: "Câmbio, inflação, juros... Será que o cenário econômico é tão ruim quanto parece? Conversamos com economistas para separar o pânico dos fatos.",
        imageURL: nil,
        duration: 4680,
        explicit: false
    )

    static let mockOld = PodcastEpisode(
        id: "mock-old",
        title: "Especial: Um Ano de Medo e Delírio",
        pubDate: Date().addingTimeInterval(-3600 * 24 * 45),
        audioURL: URL(string: "https://example.com/ep4.mp3")!,
        description: nil,
        imageURL: nil,
        duration: 7200,
        explicit: false
    )

    static let mockShort = PodcastEpisode(
        id: "mock-short",
        title: "Minuto Político: Resumo da Semana",
        pubDate: Date().addingTimeInterval(-3600 * 24 * 3),
        audioURL: URL(string: "https://example.com/ep5.mp3")!,
        description: "O resumo dos principais acontecimentos políticos da semana em menos de dez minutos.",
        imageURL: nil,
        duration: 540,
        explicit: false
    )

    static let mocks: [PodcastEpisode] = [
        .mockRecent,
        .mockYesterday,
        .mockLastWeek,
        .mockShort,
        .mockOld,
    ]
}
