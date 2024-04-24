//
//  MockSoundListViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 14/04/24.
//

import Combine

class MockSoundListViewModel: ObservableObject {

    @Published var sounds: [Sound] = Sound.sampleSounds

    var allSoundsPublisher: AnyPublisher<[Sound], Never> {
        $sounds.eraseToAnyPublisher()
    }
}
