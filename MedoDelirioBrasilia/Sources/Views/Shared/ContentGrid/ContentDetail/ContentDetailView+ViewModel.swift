//
//  ContentDetailView+ViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 23/11/24.
//

import SwiftUI

extension ContentDetailView {

    @MainActor
    final class ViewModel: ObservableObject {

        internal let content: AnyEquatableMedoContent
        private let openAuthorDetailsAction: (Author) -> Void
        internal let authorId: String?
        private let openReactionAction: (Reaction) -> Void
        private let reactionId: String?
        private let dismissAction: () -> Void

        @Published var isPlaying: Bool = false
        @Published var soundStatistics: ContentStatisticsState<ContentShareCountStats> = .loading
        @Published var reactionsState: LoadingState<[Reaction]> = .loading
        @Published var showAuthorSuggestionEmailAppPicker: Bool = false
        @Published var showReactionSuggestionEmailAppPicker: Bool = false
        @Published var didCopySupportAddressOnEmailPicker: Bool = false

        @Published var toast: Toast?

        // Alerts
        @Published var alertTitle: String = ""
        @Published var alertMessage: String = ""
        @Published var showAlert: Bool = false

        // MARK: - Initializer

        init(
            content: AnyEquatableMedoContent,
            openAuthorDetailsAction: @escaping (Author) -> Void,
            authorId: String?,
            openReactionAction: @escaping (Reaction) -> Void,
            reactionId: String?,
            dismissAction: @escaping () -> Void
        ) {
            self.content = content
            self.openAuthorDetailsAction = openAuthorDetailsAction
            self.authorId = authorId
            self.openReactionAction = openReactionAction
            self.reactionId = reactionId
            self.dismissAction = dismissAction
        }
    }
}

// MARK: - User Actions

extension ContentDetailView.ViewModel {

    func onViewLoaded() async {
        await loadStatistics()
        await loadReactions()
    }

    func onPlaySoundSelected() {
        play(content)
    }

    func onAuthorSelected() {
        guard
            !content.authorId.isEmpty,
            let author = try? LocalDatabase.shared.author(withId: content.authorId)
        else { return }
        openAuthorDetailsAction(author)
    }

    func onEditAuthorSelected() {
        showAuthorSuggestionEmailAppPicker = true
    }

    func onRetryLoadStatisticsSelected() async {
        await loadStatistics()
    }

    func onReactionSelected(reaction: Reaction) {
        if reaction.id == reactionId {
            dismissAction()
        } else {
            openReactionAction(reaction)
        }
    }

    func onSuggestAddToReactionSelected() {
        showReactionSuggestionEmailAppPicker = true
    }

    func onRetryLoadReactionsSelected() async {
        await loadReactions()
    }

    func onSoundIdSelected() {
        UIPasteboard.general.string = content.id
        toast = Toast(
            message: "ID do som copiado com sucesso!",
            type: .success
        )
    }
}

// MARK: - Internal Functions

extension ContentDetailView.ViewModel {

    private func play(_ content: AnyEquatableMedoContent) {
        do {
            let url = try content.fileURL()

            isPlaying = true

            AudioPlayer.shared = AudioPlayer(url: url, update: { state in
                if state?.activity == .stopped {
                    self.isPlaying = false
                }
            })

            AudioPlayer.shared?.togglePlay()
        } catch {
            if content.isFromServer ?? false {
                showServerSoundNotAvailableAlert()
            } else {
                showUnableToGetSoundAlert()
            }
        }
    }

    private func loadStatistics() async {
        soundStatistics = .loading
        let url = URL(string: NetworkRabbit.shared.serverPath + "v3/sound-share-count-stats-for/\(content.id)")!
        do {
            let stats: ContentShareCountStats = try await NetworkRabbit.shared.get(from: url)
            soundStatistics = .loaded(stats)
        } catch NetworkRabbitError.resourceNotFound {
            soundStatistics = .noDataYet
        } catch {
            debugPrint(error.localizedDescription)
            soundStatistics = .error(error.localizedDescription)
        }
    }

    private func loadReactions() async {
        reactionsState = .loading
        let url = URL(string: NetworkRabbit.shared.serverPath + "v4/reactions-for-sound/\(content.id)")!
        do {
            var reactions: [ReactionDTO] = try await NetworkRabbit.shared.get(from: url)
            reactions.sort(by: { $0.position < $1.position })
            reactionsState = .loaded(reactions.map { Reaction(dto: $0, type: .regular) })
        } catch {
            debugPrint(error.localizedDescription)
            reactionsState = .error(error.localizedDescription)
        }
    }

    private func showUnableToGetSoundAlert() {
        TapticFeedback.error()
        alertTitle = Shared.contentNotFoundAlertTitle(content.title)
        alertMessage = Shared.contentNotFoundAlertMessage
        showAlert = true
    }

    private func showServerSoundNotAvailableAlert() {
        TapticFeedback.error()
        alertTitle = Shared.contentNotFoundAlertTitle(content.title)
        alertMessage = Shared.serverContentNotAvailableMessage
        showAlert = true
    }
}
