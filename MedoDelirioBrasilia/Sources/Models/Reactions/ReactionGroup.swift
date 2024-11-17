//
//  ReactionGroup.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 17/11/24.
//

import Foundation

struct ReactionGroup: Identifiable, Equatable {

    let pinned: [Reaction]
    let regular: [Reaction]

    var id: String {
        let pinnedIds = pinned.map { $0.id }.joined(separator: "-")
        let regularIds = regular.map { $0.id }.joined(separator: "-")
        let combinedString = "\(pinnedIds)|\(regularIds)"
        return combinedString.hashValue.description
    }
}
