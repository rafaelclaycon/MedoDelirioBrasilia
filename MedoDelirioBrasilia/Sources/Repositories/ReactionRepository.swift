//
//  ReactionRepository.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 26/10/24.
//

import Foundation

protocol ReactionRepositoryProtocol {

    func allReactions() async throws -> [Reaction]
    func reaction(_ reactionId: String) async throws -> Reaction
    func reactionContent(reactionId: String) async throws -> [ReactionContent]
    func pinnedReactions(_ serverReactions: [Reaction]) async throws -> [Reaction]
    func savePin(reaction: Reaction) throws
    func removePin(reactionId: String) throws
}

final class ReactionRepository: ReactionRepositoryProtocol {

    private let apiClient: APIClientProtocol
    private let database: LocalDatabaseProtocol

    // MARK: - Initializer

    init(
        apiClient: APIClientProtocol = APIClient(serverPath: APIConfig.apiURL),
        database: LocalDatabaseProtocol = LocalDatabase()
    ) {
        self.apiClient = apiClient
        self.database = database
    }

    func allReactions() async throws -> [Reaction] {
        let url = URL(string: apiClient.serverPath + "v4/reactions")!
        let dtos: [ReactionDTO] = try await apiClient.get(from: url)
        let reactions: [Reaction] = dtos.map { Reaction(dto: $0, type: .regular) }
        return reactions.sorted(by: { $0.position < $1.position })
    }

    func reaction(_ reactionId: String) async throws -> Reaction {
        let url = URL(string: apiClient.serverPath + "v4/reaction/\(reactionId)")!
        let dto: ReactionDTO = try await apiClient.get(from: url)
        return Reaction(dto: dto, type: .regular) // Maybe change?
    }

    func reactionContent(reactionId: String) async throws -> [ReactionContent] {
        let url = URL(string: apiClient.serverPath + "v4/reaction-sounds/\(reactionId)")!
        let reactionSounds: [ReactionContent] = try await apiClient.get(from: url)
        return reactionSounds.sorted(by: { $0.position < $1.position })
    }

    func pinnedReactions(_ serverReactions: [Reaction]) async throws -> [Reaction] {
        let dbPinned = try database.pinnedReactions()

        let serverReactionsById = Dictionary(uniqueKeysWithValues: serverReactions.map { ($0.id, $0) })

        return dbPinned.map { pinnedReaction in
            if let serverReaction = serverReactionsById[pinnedReaction.id] {
                return Reaction(
                    id: serverReaction.id,
                    title: serverReaction.title,
                    position: pinnedReaction.position,
                    image: serverReaction.image,
                    lastUpdate: serverReaction.lastUpdate,
                    type: .pinnedExisting,
                    attributionText: serverReaction.attributionText,
                    attributionURL: serverReaction.attributionURL
                )
            } else {
                return Reaction(
                    id: pinnedReaction.id,
                    title: pinnedReaction.title,
                    position: pinnedReaction.position,
                    image: "",
                    type: .pinnedRemoved
                )
            }
        }
    }

    func savePin(reaction: Reaction) throws {
        try database.insert(reaction)
    }

    func removePin(reactionId: String) throws {
        try database.delete(reactionId: reactionId)
    }
}
