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

        @Published var showIssueSavingPinAlert: Bool = false
        @Published var showIssueRemovingPinAlert: Bool = false

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

    public func onViewLoaded() async {
        await loadReactions()
    }

    public func onTryAgainSelected() async {
        await loadReactions()
    }

    public func onPullToRefresh() async {
        await loadReactions()
    }

    public func onPinReactionSelected(reaction: Reaction) {
        do {
            try reactionRepository.savePin(reaction: reaction)
            addToPinned(reaction: reaction)

            Analytics().send(
                originatingScreen: "ReactionsView",
                action: "pinnedReaction(\(reaction.title))"
            )
        } catch {
            showIssueSavingPinAlert = true
        }
    }

    public func onUnpinReactionSelected(reaction: Reaction) async {
        do {
            try reactionRepository.removePin(reactionId: reaction.id)
            // I decided to reload the entire view because dealing with `position` proved convoluted.
            await loadReactions()

            Analytics().send(
                originatingScreen: "ReactionsView",
                action: "unpinnedReaction(\(reaction.title))"
            )
        } catch {
            showIssueRemovingPinAlert = true
        }
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
        } catch {
            state = .error(error.localizedDescription)

            Analytics().send(
                originatingScreen: "ReactionsView",
                action: "hadIssueLoadingReactions(\(error.localizedDescription))"
            )
        }
    }

    private func addToPinned(reaction: Reaction) {
        if case .loaded(let group) = state {
            var updatedGroup = group
            var updatedReaction = reaction
            updatedReaction.type = .pinnedExisting
            updatedGroup.pinned.append(updatedReaction)
            updatedGroup.regular.removeAll(where: { $0.id == reaction.id })
            state = .loaded(updatedGroup)
        }
    }
}
