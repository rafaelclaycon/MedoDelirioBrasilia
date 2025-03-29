//
//  MockSoundListViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 14/04/24.
//

import Combine

class MockSoundListViewModel: ObservableObject {

    @Published var sounds: [AnyEquatableMedoContent] = Sound.sampleSounds.map { AnyEquatableMedoContent($0) }

    var allSoundsPublisher: AnyPublisher<[AnyEquatableMedoContent], Never> {
        $sounds.eraseToAnyPublisher()
    }
}
