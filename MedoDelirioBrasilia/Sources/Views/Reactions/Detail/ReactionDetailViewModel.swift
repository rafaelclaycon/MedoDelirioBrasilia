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
    @Published var sounds: [Sound] = []
    @Published var soundSortOption: Int = ReactionSoundSortOption.default.rawValue

    let reaction: Reaction

    // MARK: - Computed Properties

    var soundsPublisher: AnyPublisher<[Sound], Never> {
        $sounds.eraseToAnyPublisher()
    }

    var subtitle: String {
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
    }

    // MARK: - Functions

    func loadSounds() async {
        state = .loading

        do {
            let url = URL(string: NetworkRabbit.shared.serverPath + "v4/reaction/\(reaction.id)")!
            let reactionSounds: [ReactionSound] = try await NetworkRabbit.get(from: url)
            let soundIds: [String] = reactionSounds.map { $0.soundId }
            let selectedSounds = try LocalDatabase.shared.sounds(withIds: soundIds)
            self.sounds = selectedSounds
            DispatchQueue.main.async {
                self.state = .loaded(self.sounds)
            }
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
