//
//  SoundListDisplaying.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 16/04/24.
//

import SwiftUI

/// This protocol exists to enable the communication between ContextMenuOption and ContentList.
protocol SoundListDisplaying {

    func share(sound: Sound)

    func openShareAsVideoModal(for sound: Sound)

    func toggleFavorite(_ soundId: String)

    func addToFolder(_ sound: Sound)

    func playFrom(sound: Sound)

    func removeFromFolder(_ sound: Sound)

    func showDetails(for sound: Sound)

    func showAuthor(withId authorId: String)

    func suggestOtherAuthorName(for sound: Sound)
}
