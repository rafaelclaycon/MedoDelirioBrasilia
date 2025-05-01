//
//  ReactionService.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 16/04/25.
//

import Foundation

protocol ReactionServiceProtocol {

    /// Returns a Reaction with the given ID.
    func reaction(_ reactionId: String) async throws -> Reaction

    /// Returns all content for a given Reaction ID.
    func reactionContent(
        for reactionId: String,
        _ allowSensitive: Bool,
        _ sortOrder: ReactionSoundSortOption
    ) async throws -> [AnyEquatableMedoContent]
}

final class ReactionService: ReactionServiceProtocol {

    private let reactionRepository: ReactionRepositoryProtocol
    private let contentRepository: ContentRepositoryProtocol

    private var reactionId: String = ""
    private var serverContent: [ReactionContent] = []

    // MARK: - Initializer

    init(
        reactionRepository: ReactionRepositoryProtocol,
        contentRepository: ContentRepositoryProtocol
    ) {
        self.reactionRepository = reactionRepository
        self.contentRepository = contentRepository
    }

    func reaction(_ reactionId: String) async throws -> Reaction {
        try await reactionRepository.reaction(reactionId)
    }

    func reactionContent(
        for reactionId: String,
        _ allowSensitive: Bool,
        _ sortOrder: ReactionSoundSortOption
    ) async throws -> [AnyEquatableMedoContent] {
        if reactionId != self.reactionId {
            self.reactionId = reactionId
            serverContent = try await reactionRepository.reactionContent(reactionId: reactionId)
        }
        guard !serverContent.isEmpty else { return [] }
        let soundIds: [String] = serverContent.map { $0.soundId }
        var content = try contentRepository.content(withIds: soundIds)

        for i in stride(from: 0, to: content.count, by: 1) {
            if let reactionSound = serverContent.first(where: { $0.soundId == content[i].id }) {
                content[i].dateAdded = reactionSound.dateAdded.iso8601withFractionalSeconds
            }
        }

        return reactionSort(content: content, by: sortOrder)
    }
}

extension ReactionService {

    private func reactionSort(content: [AnyEquatableMedoContent], by sortOption: ReactionSoundSortOption) -> [AnyEquatableMedoContent] {
        switch sortOption {
        case .default:
            sortedByServerPosition(content)
        case .dateAddedDescending:
            content.sorted(by: { $0.dateAdded ?? Date() > $1.dateAdded ?? Date() })
        case .dateAddedAscending:
            content.sorted(by: { $0.dateAdded ?? Date() < $1.dateAdded ?? Date() })
        }
    }

    private func sortedByServerPosition(_ content: [AnyEquatableMedoContent]) -> [AnyEquatableMedoContent] {
        guard !serverContent.isEmpty, !content.isEmpty else { return [] }
        let indexMap = Dictionary(uniqueKeysWithValues: serverContent.enumerated().map { ($1.soundId, $0) })

        return content.sorted { (item1, item2) -> Bool in
            guard let index1 = indexMap[item1.id], let index2 = indexMap[item2.id] else {
                return false
            }
            return index1 < index2
        }
    }
}
