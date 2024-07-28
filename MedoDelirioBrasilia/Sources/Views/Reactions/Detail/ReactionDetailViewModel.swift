//
//  ReactionDetailViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 30/04/24.
//

import SwiftUI
import Combine

class ReactionDetailViewModel: ObservableObject {

    // MARK: - Published Vars

    @Published var state: LoadingState<Sound> = .loading
    @Published var sounds: [Sound]?
    @Published var soundSortOption: Int

    let reaction: Reaction
    var reactionSounds: [ReactionSound]?

    // MARK: - Computed Properties

    var soundsPublisher: AnyPublisher<[Sound], Never> {
        $sounds
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }

    var subtitle: String {
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

    // MARK: - Initializer

    init(
        reaction: Reaction
    ) {
        self.reaction = reaction
        self.soundSortOption = 0
    }
}

// MARK: - Sound Loading

extension ReactionDetailViewModel {

    func loadSounds() async {
        DispatchQueue.main.async {
            self.state = .loading
        }

        do {
            self.reactionSounds = try await soundsFromServer()
            guard let reactionSounds else { return }
            let soundIds: [String] = reactionSounds.map { $0.soundId }
            var selectedSounds = try LocalDatabase.shared.sounds(withIds: soundIds)

            for i in 0..<selectedSounds.count {
                if let reactionSound = reactionSounds.first(where: { $0.soundId == selectedSounds[i].id }) {
                    selectedSounds[i].dateAdded = reactionSound.dateAdded.iso8601withFractionalSeconds
                }
            }

            DispatchQueue.main.async {
                self.sounds = selectedSounds
                self.state = .loaded(selectedSounds)
            }
        } catch {
            DispatchQueue.main.async {
                self.state = .error(error.localizedDescription)
            }
            Analytics.send(
                originatingScreen: "ReactionDetailView",
                action: "hadIssueWithReaction(\(self.reaction.title) - \(error.localizedDescription))"
            )
        }
    }

    private func soundsFromServer() async throws -> [ReactionSound] {
        let url = URL(string: NetworkRabbit.shared.serverPath + "v4/reaction/\(reaction.id)")!
        var reactionSounds: [ReactionSound] = try await NetworkRabbit.get(from: url)
        return reactionSounds.sorted(by: { $0.position < $1.position })
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

        DispatchQueue.main.async {
            self.sounds = sortedSounds
        }
    }

    private func sortSoundsByDateAddedDescending() {
        DispatchQueue.main.async {
            self.sounds?.sort(by: { $0.dateAdded ?? Date() > $1.dateAdded ?? Date() })
        }
    }

    private func sortSoundsByDateAddedAscending() {
        DispatchQueue.main.async {
            self.sounds?.sort(by: { $0.dateAdded ?? Date() < $1.dateAdded ?? Date() })
        }
    }
}
