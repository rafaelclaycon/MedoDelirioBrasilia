//
//  ReactionRepository.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 26/10/24.
//

import Foundation

protocol ReactionRepositoryProtocol {

    func allReactions() async throws -> [Reaction]
    func reactionSounds(reactionId: String) async throws -> [ReactionSound]
}

final class ReactionRepository: ReactionRepositoryProtocol {

    private let apiClient: NetworkRabbit

    // MARK: - Initializer

    init(
        apiClient: NetworkRabbit = NetworkRabbit(serverPath: APIConfig.apiURL)
    ) {
        self.apiClient = apiClient
    }

    func allReactions() async throws -> [Reaction] {
        let url = URL(string: apiClient.serverPath + "v4/reactions")!
        let reactions: [Reaction] = try await apiClient.get(from: url)
        return reactions.sorted(by: { $0.position < $1.position })
    }

    func reactionSounds(reactionId: String) async throws -> [ReactionSound] {
        let url = URL(string: apiClient.serverPath + "v4/reaction/\(reactionId)")!
        let reactionSounds: [ReactionSound] = try await apiClient.get(from: url)
        return reactionSounds.sorted(by: { $0.position < $1.position })
    }
}
