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

        @Published var state: LoadingState<[Reaction]> = .loading
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
            let reactions = try await reactionRepository.allReactions()
            state = .loaded(reactions)

            Analytics().send(
                originatingScreen: "ReactionsView",
                action: "didViewReactionsTab"
            )
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
