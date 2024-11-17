//
//  FakeReactionRepository.swift
//  MedoDelirioBrasiliaTests
//
//  Created by Rafael Schmitt on 17/11/24.
//

import Foundation
@testable import MedoDelirio

final class FakeReactionRepository: ReactionRepositoryProtocol {

    var didCallAllReactions = false
    var didCallReaction = false
    var didCallReactionSounds = false
    var didCallPinnedReactions = false

    func allReactions() async throws -> [Reaction] {
        didCallAllReactions = true
        return []
    }

    func reaction(_ reactionId: String) async throws -> Reaction {
        didCallReaction = true
        return Reaction(title: "", image: "")
    }

    func reactionSounds(reactionId: String) async throws -> [ReactionSound] {
        didCallReactionSounds = true
        return []
    }

    func pinnedReactions() async throws -> [String] {
        didCallPinnedReactions = true
        return []
    }
}
