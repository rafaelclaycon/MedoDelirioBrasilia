//
//  SoundListRouter.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 20/07/24.
//

import SwiftUI

enum GeneralNavigationDestination: Hashable {
    case authorDetail(Author)
    case reactionDetail(Reaction)
}

struct GeneralRouter: View {

    let destination: GeneralNavigationDestination

    @State private var currentSoundListMode: SoundsListMode = .regular

    var body: some View {
        switch destination {
        case .authorDetail(let author):
            AuthorDetailView(
                author: author,
                currentSoundsListMode: $currentSoundListMode
            )
        case .reactionDetail(let reaction):
            ReactionDetailView(
                reaction: reaction,
                currentSoundsListMode: $currentSoundListMode
            )
        }
    }
}

enum WPNavigationDestination: Hashable {
    case sounds
}

struct WPRouter: View {

    let destination: WPNavigationDestination

    var body: some View {
        switch destination {
        case .sounds:
            WPSoundsView(
                viewModel: .init(
                    currentViewMode: .allSounds,
                    soundSortOption: UserSettings().mainSoundListSoundSortOption(),
                    authorSortOption: UserSettings().authorSortOption(),
                    currentSoundsListMode: .constant(.regular),
                    syncValues: SyncValues()
                )
            )
        }
    }
}
