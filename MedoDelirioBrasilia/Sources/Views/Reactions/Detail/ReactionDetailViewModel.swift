//
//  ReactionDetailViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 30/04/24.
//

import SwiftUI
import Combine

@MainActor
class ReactionDetailViewModel: ObservableObject {

    // MARK: - Published Vars

    @Published var state: ReactionDetailState<[Sound]> = .loading
    @Published var sounds: [Sound]?
    @Published var soundSortOption: Int

    public var reaction: Reaction
    private var reactionSounds: [ReactionSound]? // Needed for ordering by position.
    private let reactionRepository: ReactionRepositoryProtocol

    // MARK: - Computed Properties

    var soundsPublisher: AnyPublisher<[Sound], Never> {
        $sounds
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }

    var subtitle: String {
        guard !dataLoadingDidFail else { return "" }
        guard let sounds else { return "Carregando..." }
        let lastUpdateDate: String = reaction.lastUpdate.asRelativeDateTime ?? ""
        if sounds.count == 0 {
            return "Nenhum som. Atualizada \(lastUpdateDate)."
        } else if sounds.count == 1 {
            return "1 som. Atualizada \(lastUpdateDate)."
        } else {
            return "\(sounds.count) sons. Atualizada \(lastUpdateDate)."
        }
    }

    var dataLoadingDidFail: Bool {
        if case .soundLoadingError = state { return true }
        if case .reactionNoLongerExists = state { return true }
        return false
    }

    var errorMessage: String {
        // The reactionNoLongerExists case is dealt with in the view itself.
        guard case .soundLoadingError(let errorString) = state else { return "" }
        return errorString
    }

    // MARK: - Initializer

    init(
        reaction: Reaction,
        reactionRepository: ReactionRepositoryProtocol = ReactionRepository()
    ) {
        self.reaction = reaction
        self.soundSortOption = 0
        self.reactionRepository = reactionRepository
    }
}

// MARK: - Sound Loading

extension ReactionDetailViewModel {

    func loadSounds() async {
        state = .loading

        do {
            let reaction = try await reactionRepository.reaction(reaction.id)
            self.reaction.lastUpdate = reaction.lastUpdate
            self.reaction.attributionText = reaction.attributionText
            self.reaction.attributionURL = reaction.attributionURL
        } catch NetworkRabbitError.resourceNotFound {
            state = .reactionNoLongerExists
            return
        } catch {
            state = .soundLoadingError(error.localizedDescription)
            Analytics().send(
                originatingScreen: "ReactionDetailView",
                action: "hadIssueWithReaction(\(self.reaction.title) - \(error.localizedDescription))"
            )
            return
        }

        do {
            self.reactionSounds = try await reactionRepository.reactionSounds(reactionId: reaction.id)
            guard let reactionSounds else { return }
            let soundIds: [String] = reactionSounds.map { $0.soundId }
            var selectedSounds = try LocalDatabase.shared.sounds(withIds: soundIds)

            for i in 0..<selectedSounds.count {
                if let reactionSound = reactionSounds.first(where: { $0.soundId == selectedSounds[i].id }) {
                    selectedSounds[i].dateAdded = reactionSound.dateAdded.iso8601withFractionalSeconds
                }
            }

            sounds = selectedSounds
            state = .loaded(selectedSounds)
        } catch {
            state = .soundLoadingError(error.localizedDescription)
            Analytics().send(
                originatingScreen: "ReactionDetailView",
                action: "hadIssueWithReaction(\(self.reaction.title) - \(error.localizedDescription))"
            )
        }
    }
}

// MARK: - Sound Sorting

extension ReactionDetailViewModel {

    func sortSounds(by rawSortOption: Int) {
        let sortOption = ReactionSoundSortOption(rawValue: rawSortOption) ?? .default
        switch sortOption {
        case .default:
            sortSoundsByServerPosition()
        case .dateAddedDescending:
            sortSoundsByDateAddedDescending()
        case .dateAddedAscending:
            sortSoundsByDateAddedAscending()
        }
    }

    private func sortSoundsByServerPosition() {
        guard let reactionSounds, let sounds else { return }
        let indexMap = Dictionary(uniqueKeysWithValues: reactionSounds.enumerated().map { ($1.soundId, $0) })

        let sortedSounds = sounds.sorted { (item1, item2) -> Bool in
            guard let index1 = indexMap[item1.id], let index2 = indexMap[item2.id] else {
                return false
            }
            return index1 < index2
        }

        self.sounds = sortedSounds
    }

    private func sortSoundsByDateAddedDescending() {
        sounds?.sort(by: { $0.dateAdded ?? Date() > $1.dateAdded ?? Date() })
    }

    private func sortSoundsByDateAddedAscending() {
        sounds?.sort(by: { $0.dateAdded ?? Date() < $1.dateAdded ?? Date() })
    }
}
