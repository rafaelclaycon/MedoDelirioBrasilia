//
//  FakeReactionRepository.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 17/11/24.
//

import Foundation

final class FakeReactionRepository: ReactionRepositoryProtocol {

    var didCallAllReactions = false
    var didCallReaction = false
    var didCallReactionSounds = false
    var didCallPinnedReactions = false
    var didCallSavePin = false
    var didCallRemovePin = false

    func allReactions() async throws -> [Reaction] {
        didCallAllReactions = true
        return []
    }

    func reaction(_ reactionId: String) async throws -> Reaction {
        didCallReaction = true
        return Reaction(id: reactionId, title: "Test Reaction", image: "https://example.com/image.jpg")
    }

    func reactionContent(reactionId: String) async throws -> [ReactionContent] {
        didCallReactionSounds = true
        return []
    }

    func pinnedReactions(_ serverReactions: [Reaction]) async throws -> [Reaction] {
        didCallPinnedReactions = true
        return []
    }

    func savePin(reaction: Reaction) throws {
        didCallSavePin = true
    }

    func removePin(reactionId: String) throws {
        didCallRemovePin = true
    }
}
