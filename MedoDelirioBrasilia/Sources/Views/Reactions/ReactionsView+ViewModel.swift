//
//  ReactionsView+ViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import SwiftUI
import Combine

extension ReactionsView {

    @MainActor
    final class ViewModel: ObservableObject {

        @Published var state: LoadingState<ReactionGroup> = .loading
        @Published var showHowReactionsWorkSheet: Bool = false
        @Published var showAddStuffSheet: Bool = false

        private let reactionRepository: ReactionRepositoryProtocol

        // MARK: - Initializer

        init(
            reactionRepository: ReactionRepositoryProtocol
        ) {
            self.reactionRepository = reactionRepository
        }
    }
}

// MARK: - User Actions

extension ReactionsView.ViewModel {

    public func onViewLoad() async {
        await loadReactions()
    }

    public func onTryAgainSelected() async {
        await loadReactions()
    }

    public func onPullToRefresh() async {
        await loadReactions()
    }
}

// MARK: - Internal Functions

extension ReactionsView.ViewModel {

    private func loadReactions() async {
        state = .loading

        do {
            let serverReactions = try await reactionRepository.allReactions()
            let pinned = try await reactionRepository.pinnedReactions(serverReactions)

            let regular: [Reaction] = serverReactions.compactMap { serverReaction in
                guard !pinned.contains(where: { $0.id == serverReaction.id }) else { return nil }
                return serverReaction
            }

            state = .loaded(.init(pinned: pinned, regular: regular))

            Analytics().send(
                originatingScreen: "ReactionsView",
                action: "didViewReactionsTab"
            )
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
