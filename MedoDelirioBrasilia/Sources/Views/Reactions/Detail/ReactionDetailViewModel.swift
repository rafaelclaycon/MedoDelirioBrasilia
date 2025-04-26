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
    public var toast: Binding<Toast?>
    public var floatingOptions: Binding<FloatingContentOptions?>
    private let reactionService: ReactionServiceProtocol

    // MARK: - Computed Properties

    var subtitle: String {
        if case .loading = state { return "Carregando..." }
        guard case .loaded(let content) = state else { return "" }
        let lastUpdateDate: String = reaction.lastUpdate.asRelativeDateTime ?? ""
        if content.count == 0 {
            return "Reação vazia. Atualizada \(lastUpdateDate)."
        } else if content.count == 1 {
            return "1 item. Atualizada \(lastUpdateDate)."
        } else {
            return "\(content.count) itens. Atualizada \(lastUpdateDate)."
        }
    }

    var errorMessage: String {
        guard case .error(let errorString) = state else { return "" }
        return errorString
    }

    // MARK: - Initializer

    init(
        reaction: Reaction,
        toast: Binding<Toast?>,
        floatingOptions: Binding<FloatingContentOptions?>,
        contentRepository: ContentRepositoryProtocol
    ) {
        self.reaction = reaction
        self.toast = toast
        self.floatingOptions = floatingOptions
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

    public func onContentSortingChanged() async {
        await loadContent(enterLoadingState: false)
    }
}

// MARK: - Internal Functions

extension ReactionDetailViewModel {

    private func loadContent(enterLoadingState: Bool = true) async {
        if enterLoadingState {
            state = .loading
        }
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
            await AnalyticsService().send(
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
            await AnalyticsService().send(
                originatingScreen: "ReactionDetailView",
                action: "hadIssueWithReaction(\(self.reaction.title) - \(error.localizedDescription))"
            )
        }
    }
}
