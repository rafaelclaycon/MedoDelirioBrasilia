//
//  SearchResultSection.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 20/01/25.
//

import Foundation

enum SearchResultSection: String, CaseIterable {

    case sounds = "Sons"
    case authors = "Autores"
    case folders = "Pastas"
    case songs = "Músicas"
    case reactions = "Reações"
}

struct SearchResults {

    var content: [AnyEquatableMedoContent]?
    var authors: [Author]?
    var folders: [UserFolder]?
    var songs: [Song]?
    var reactions: [Reaction]?

    public mutating func clearAll() {
        self.content = []
        self.authors = []
        self.folders = []
        self.songs = []
        self.reactions = []
    }
}
