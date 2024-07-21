//
//  SoundListRouter.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 20/07/24.
//

import SwiftUI

enum SoundListNavigationDestination: Hashable {
    case authorDetail(Author)
}

struct SoundListRouter: View {

    let destination: SoundListNavigationDestination

    @State private var currentSoundListMode: SoundsListMode = .regular

    var body: some View {
        switch destination {
        case .authorDetail(let author):
            AuthorDetailView(author: author, currentSoundsListMode: $currentSoundListMode)
        }
    }
}
