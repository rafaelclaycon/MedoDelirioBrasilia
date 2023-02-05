//
//  SoundInMix.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 05/02/23.
//

import SwiftUI

struct SoundInMix {

    var sound: Sound
    var positionOnList: Int
    var color: Color
    
    init(sound: Sound,
         positionOnList: Int,
         color: Color) {
        self.sound = sound
        self.positionOnList = positionOnList
        self.color = color
    }

}
