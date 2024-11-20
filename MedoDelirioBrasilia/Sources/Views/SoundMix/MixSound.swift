//
//  MixSound.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 20/11/24.
//

import Foundation

struct MixSound {

    let position: Int
    let sound: Sound

    init(
        position: Int,
        sound: Sound
    ) {
        self.position = position
        self.sound = sound
    }
}
