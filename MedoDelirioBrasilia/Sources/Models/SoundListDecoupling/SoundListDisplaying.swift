//
//  SoundListDisplaying.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 16/04/24.
//

import SwiftUI

/// This protocol exists to enable the communication between ContextMenuOption and SoundList.

protocol SoundListDisplaying {

    func share(sound: Sound)

    func openShareAsVideoModal(for sound: Sound)

    func toggleFavorite(_ soundId: String)

    func addToFolder(_ sound: Sound)

    func playFrom(sound: Sound)

    func removeFromFolder(_ sound: Sound)
}
