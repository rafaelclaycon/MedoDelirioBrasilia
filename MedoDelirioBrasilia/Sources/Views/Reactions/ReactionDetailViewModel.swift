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

    @Published var sounds: [Sound] = []
    @Published var soundSortOption: Int = ReactionSoundSortOption.default.rawValue

    let reaction: Reaction

    // MARK: - Computed Properties

    var soundsPublisher: AnyPublisher<[Sound], Never> {
        $sounds.eraseToAnyPublisher()
    }

    var subtitle: String {
        if sounds.count == 0 {
            return "Nenhum som. Atualizada agora mesmo."
        } else if sounds.count == 1 {
            return "1 som. Atualizada agora mesmo."
        } else {
            return "\(sounds.count) sons. Atualizada agora mesmo."
        }
    }

    // MARK: - Initializer

    init(
        reaction: Reaction
    ) {
        self.reaction = reaction
    }

    // MARK: - Functions

    func loadSounds() {
        do {
            sounds = try LocalDatabase.shared.randomSounds()

            guard sounds.count > 0 else { return }
            // let sortOption: SoundSortOption = SoundSortOption(rawValue: UserSettings.getSoundSortOption()) ?? .dateAddedDescending
            // sort(&allSounds, by: sortOption)
        } catch {
            print("Erro carregando sons: \(error.localizedDescription)")
        }
    }
}
