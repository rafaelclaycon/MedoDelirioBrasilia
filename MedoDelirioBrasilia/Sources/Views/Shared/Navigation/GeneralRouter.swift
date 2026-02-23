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
    case folderDetail(UserFolder)
    case episodeDetail(PodcastEpisode)
}

enum SearchNavigationDestination: Hashable {

    case trends
}

struct GeneralRouter: View {

    let destination: GeneralNavigationDestination
    let contentRepository: ContentRepositoryProtocol

    @State private var currentContentListMode: ContentGridMode = .regular
    @State private var toast: Toast?
    @State private var floatingOptions: FloatingContentOptions?

    var body: some View {
        switch destination {
        case .authorDetail(let author):
            AuthorDetailView(
                viewModel: AuthorDetailViewModel(
                    author: author,
                    currentContentListMode: $currentContentListMode,
                    toast: $toast,
                    floatingOptions: $floatingOptions,
                    contentRepository: contentRepository
                ),
                currentListMode: $currentContentListMode,
                contentRepository: contentRepository
            )

        case .reactionDetail(let reaction):
            ReactionDetailView(
                viewModel: ReactionDetailViewModel(
                    reaction: reaction,
                    toast: $toast,
                    floatingOptions: $floatingOptions,
                    contentRepository: contentRepository
                ),
                currentListMode: $currentContentListMode,
                contentRepository: contentRepository
            )

        case .folderDetail(let folder):
            FolderDetailView(
                viewModel: FolderDetailViewModel(
                    folder: folder,
                    contentRepository: contentRepository
                ),
                folder: folder,
                currentContentListMode: $currentContentListMode,
                toast: $toast,
                floatingOptions: $floatingOptions,
                contentRepository: contentRepository
            )

        case .episodeDetail(let episode):
            EpisodeDetailView(episode: episode)
        }
    }
}
