//
//  ReactionMock.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 02/05/24.
//

import Foundation

extension Reaction {

    static var allMocks: [Self] {
        return [
            .greetingsMock,
            .classicsMock,
            .choqueMock,
            .viralMock,
            .seriousMock,
            .enthusiasmMock,
            .acidMock,
            .sarcasticMock,
            .provokingMock,
            .slogansMock,
            .frustrationMock,
            .hopeMock,
            .surpriseMock,
            .ironyMock,
            .covid19Mock,
            .foreignMock,
            .lgbtMock,
            .jinglesMock
        ]
    }

    static var greetingsMock: Self {
        return .init(
            id: "greeting-mock-id",
            title: "saudações",
            position: 1,
            image: "https://images.unsplash.com/photo-1610548822783-33fb5cb0e3a8?q=80&w=2670&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
            lastUpdate: "2025-11-22T14:48:45.969Z",
            type: .regular,
            attributionText: nil,
            attributionURL: nil
        )
    }

    static var classicsMock: Self {
        return .init(
            id: "classics-mock-id",
            title: "clássicos",
            position: 2,
            image: "https://www.avina.net/wp-content/uploads/2019/06/Confiamos-no-Brasil-e-nos-brasileiros-e-brasileiras.jpg",
            lastUpdate: "2025-11-22T14:48:45.969Z",
            type: .regular,
            attributionText: nil,
            attributionURL: nil
        )
    }

    static var choqueMock: Self {
        return .init(
            title: "choque",
            image: "https://ogimg.infoglobo.com.br/cultura/revista-da-tv/25399261-a70-216/FT1086A/CANAL-BRASIL_Choque-de-Cultura_FOTO-David-Beninca14.JPG"
        )
    }

    static var viralMock: Self {
        return .init(
            title: "virais",
            image: "https://images.unsplash.com/photo-1579869847557-1f67382cc158?q=80&w=2668&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
        )
    }

    static var seriousMock: Self {
        return .init(
            title: "sérios",
            image: "https://images.unsplash.com/photo-1529323871863-75303b5737ec?q=80&w=1587&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
        )
    }

    static var enthusiasmMock: Self {
        return .init(
            title: "entusiasmo",
            image: "https://images.unsplash.com/photo-1489710437720-ebb67ec84dd2?q=80&w=2670&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
        )
    }

    static var acidMock: Self {
        return .init(
            title: "ácidos",
            image: "https://images.unsplash.com/photo-1591848478625-de43268e6fb8?q=80&w=2574&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
        )
    }

    static var sarcasticMock: Self {
        return .init(
            title: "sarcásticos",
            image: "https://images.unsplash.com/photo-1593183230686-69876b0cb240?q=80&w=2015&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
        )
    }

    static var provokingMock: Self {
        return .init(
            id: "provoking-mock-id",
            title: "provocação",
            position: 3,
            image: "https://images.unsplash.com/photo-1528597788073-3bf9d20118ef?q=80&w=2574&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
            lastUpdate: "2025-11-22T14:48:45.969Z",
            type: .regular,
            attributionText: nil,
            attributionURL: nil
        )
    }

    static var slogansMock: Self {
        return .init(
            title: "lemas",
            image: "https://images.unsplash.com/photo-1534180888273-50e8cca7c1e4?q=80&w=2670&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
        )
    }

    static var frustrationMock: Self {
        return .init(
            title: "frustração & desânimo",
            image: "https://images.unsplash.com/photo-1633613286880-dae9f126b728?q=80&w=2670&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
        )
    }

    static var hopeMock: Self {
        return .init(
            title: "esperança",
            image: "https://images.unsplash.com/photo-1492681290082-e932832941e6?q=80&w=2671&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
        )
    }

    static var surpriseMock: Self {
        return .init(
            title: "surpresa",
            image: "https://images.unsplash.com/photo-1567025557402-9aab2c0385d5?q=80&w=2671&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
        )
    }

    static var ironyMock: Self {
        return .init(
            title: "ironia",
            image: "https://images.unsplash.com/photo-1513682121497-80211f36a7d3?q=80&w=2576&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
        )
    }

    static var covid19Mock: Self {
        return .init(
            title: "covid-19",
            image: "https://images.unsplash.com/photo-1599493758267-c6c884c7071f?q=80&w=2670&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
        )
    }

    static var foreignMock: Self {
        return .init(
            title: "gringos",
            image: "https://images.unsplash.com/photo-1614107151491-6876eecbff89?q=80&w=2574&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
        )
    }

    static var lgbtMock: Self {
        return .init(
            title: "lgbt+",
            image: "https://images.unsplash.com/photo-1562592619-908ca07deace?q=80&w=2670&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
        )
    }

    static var jinglesMock: Self {
        return .init(
            title: "jingles",
            image: "https://images.unsplash.com/photo-1593078166039-c9878df5c520?q=80&w=2670&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
        )
    }
}
