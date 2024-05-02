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

    let reactionTitle: String

    // MARK: - Computed Properties

    var soundsPublisher: AnyPublisher<[Sound], Never> {
        $sounds.eraseToAnyPublisher()
    }

    // MARK: - Initializer

    init(
        reactionTitle: String
    ) {
        self.reactionTitle = reactionTitle
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
