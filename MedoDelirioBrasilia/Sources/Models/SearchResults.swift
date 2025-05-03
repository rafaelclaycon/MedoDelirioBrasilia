//
//  SearchResults.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 20/01/25.
//

import Foundation

//enum SearchResultSection: String, CaseIterable {
//
//    case sounds = "Sons"
//    case authors = "Autores"
//    case folders = "Pastas"
//    case songs = "Músicas"
//    case reactions = "Reações"
//}

struct SearchResults {

    var soundsMatchingTitle: [AnyEquatableMedoContent]?
    var soundsMatchingContent: [AnyEquatableMedoContent]?
    var songsMatchingTitle: [AnyEquatableMedoContent]?
    var songsMatchingContent: [AnyEquatableMedoContent]?
    var authors: [Author]?
    var folders: [UserFolder]?
    var reactionsMatchingTitle: [Reaction]?
    var reactionsMatchingFeeling: [Reaction]?

    var noResults: Bool {
        return soundsMatchingTitle?.isEmpty ?? true &&
            soundsMatchingContent?.isEmpty ?? true &&
            songsMatchingTitle?.isEmpty ?? true &&
            songsMatchingContent?.isEmpty ?? true &&
            authors?.isEmpty ?? true &&
            folders?.isEmpty ?? true &&
            reactionsMatchingTitle?.isEmpty ?? true &&
            reactionsMatchingFeeling?.isEmpty ?? true
    }

    public mutating func clearAll() {
        self.soundsMatchingTitle = nil
        self.soundsMatchingContent = nil
        self.songsMatchingTitle = nil
        self.songsMatchingContent = nil
        self.authors = nil
        self.folders = nil
        self.reactionsMatchingTitle = nil
        self.reactionsMatchingFeeling = nil
    }
}
