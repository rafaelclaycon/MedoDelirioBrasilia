//
//  MockSoundListViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 14/04/24.
//

import Combine

class MockSoundListViewModel: ObservableObject, SoundDataProvider {

    @Published var sounds: [Sound] = Sound.sampleSounds

    var soundsPublisher: AnyPublisher<[Sound], Never> {
        $sounds.eraseToAnyPublisher()
    }
}
