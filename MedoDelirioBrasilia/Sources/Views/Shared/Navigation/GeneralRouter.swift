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
    let contentRepository: ContentRepositoryProtocol

    @State private var currentContentListMode: ContentListMode = .regular
    @State private var toast: Toast?

    var body: some View {
        switch destination {
        case .authorDetail(let author):
            AuthorDetailView(
                author: author,
                currentListMode: $currentContentListMode,
                toast: $toast,
                contentRepository: contentRepository
            )
        case .reactionDetail(let reaction):
            ReactionDetailView(
                reaction: reaction,
                currentListMode: $currentContentListMode,
                toast: $toast
            )
        }
    }
}
