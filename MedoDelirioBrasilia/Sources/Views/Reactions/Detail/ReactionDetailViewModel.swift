//
//  ReactionDetailViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 30/04/24.
//

import SwiftUI

@MainActor
@Observable
class ReactionDetailViewModel {

    public var state: LoadingState<[AnyEquatableMedoContent]> = .loading
    public var reactionNoLongerExists: Bool = false

    public var contentSortOption: Int = ReactionSoundSortOption.default.rawValue

    public var reaction: Reaction
    private let reactionService: ReactionServiceProtocol

    // MARK: - Computed Properties

    var subtitle: String {
        return ""
//        guard !dataLoadingDidFail else { return "" }
//        guard let sounds else { return "Carregando..." }
//        let lastUpdateDate: String = reaction.lastUpdate.asRelativeDateTime ?? ""
//        if sounds.count == 0 {
//            return "Nenhum som. Atualizada \(lastUpdateDate)."
//        } else if sounds.count == 1 {
//            return "1 som. Atualizada \(lastUpdateDate)."
//        } else {
//            return "\(sounds.count) sons. Atualizada \(lastUpdateDate)."
//        }
    }

    var errorMessage: String {
        return ""
//        // The reactionNoLongerExists case is dealt with in the view itself.
//        guard case .soundLoadingError(let errorString) = state else { return "" }
//        return errorString
    }

    // MARK: - Initializer

    init(
        reaction: Reaction,
        contentRepository: ContentRepositoryProtocol
    ) {
        self.reaction = reaction
        self.reactionService = ReactionService(
            reactionRepository: ReactionRepository(),
            contentRepository: contentRepository
        )
    }
}

// MARK: - User Actions

extension ReactionDetailViewModel {

    public func onViewLoaded() async {
        await loadContent()
    }

    public func onRetrySelected() async {
        await loadContent()
    }
}

// MARK: - Internal Functions

extension ReactionDetailViewModel {

    private func loadContent() async {
        state = .loading
        reactionNoLongerExists = false

        do {
            let reaction = try await reactionService.reaction(reaction.id)
            self.reaction.lastUpdate = reaction.lastUpdate
            self.reaction.attributionText = reaction.attributionText
            self.reaction.attributionURL = reaction.attributionURL
        } catch NetworkRabbitError.resourceNotFound {
            state = .error("")
            reactionNoLongerExists = true
            return
        } catch {
            state = .error(error.localizedDescription)
            Analytics().send(
                originatingScreen: "ReactionDetailView",
                action: "hadIssueWithReaction(\(self.reaction.title) - \(error.localizedDescription))"
            )
            return
        }

        do {
            let allowSensitive = UserSettings().getShowExplicitContent()
            let sort = ReactionSoundSortOption(rawValue: contentSortOption) ?? .default
            state = .loaded(
                try await reactionService.reactionContent(for: reaction.id, allowSensitive, sort)
            )
        } catch {
            state = .error(error.localizedDescription)
            Analytics().send(
                originatingScreen: "ReactionDetailView",
                action: "hadIssueWithReaction(\(self.reaction.title) - \(error.localizedDescription))"
            )
        }
    }
}
