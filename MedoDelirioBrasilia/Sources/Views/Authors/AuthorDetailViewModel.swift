//
//  AuthorsDetailViewViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 19/05/22.
//

import SwiftUI

@Observable
class AuthorDetailViewModel {

    var state: LoadingState<[AnyEquatableMedoContent]> = .loading

    var soundSortOption: Int = 1
    var selectedSound: Sound? = nil
    var selectedSounds: [Sound]? = nil

    var showEmailAppPicker_suggestOtherAuthorNameConfirmationDialog = false
    var showEmailAppPicker_soundUnavailableConfirmationDialog = false
    var showEmailAppPicker_askForNewSound = false
    var showEmailAppPicker_reportAuthorDetailIssue = false
    private let authorId: String
    var currentContentListMode: Binding<ContentListMode>
    private let contentRepository: ContentRepositoryProtocol

    // Alerts
    var alertTitle: String = ""
    var alertMessage: String = ""
    var showAlert: Bool = false
    var alertType: AuthorDetailAlertType = .ok

    // MARK: - Computed Properties

    var soundCount: Int {
        guard case .loaded(let content) = state else { return 0 }
        return content.count
    }

    var soundCountText: String {
        soundCount == 1 ? "1 SOM" : "\(soundCount) SONS"
    }

    // MARK: - Initializer

    init(
        authorId: String,
        currentContentListMode: Binding<ContentListMode>,
        contentRepository: ContentRepositoryProtocol
    ) {
        self.authorId = authorId
        self.currentContentListMode = currentContentListMode
        self.contentRepository = contentRepository
    }
}


// MARK: - User Actions

extension AuthorDetailViewModel {

    public func onViewLoaded() {
        loadContent()
    }

    public func onSortOptionChanged() {
        loadContent()
    }
}

// MARK: - Internal Functions

extension AuthorDetailViewModel {

    private func loadContent() {
        state = .loading
        do {
            let allowSensitive = UserSettings().getShowExplicitContent()
            let sort = SoundSortOption(rawValue: soundSortOption) ?? .dateAddedDescending
            state = .loaded(try contentRepository.content(by: authorId, allowSensitive, sort))
        } catch {
            state = .error(error.localizedDescription)
            debugPrint(error)
        }
    }

    public func showAskForNewSoundAlert() {
        TapticFeedback.warning()
        alertType = .askForNewSound
        alertTitle = Shared.AuthorDetail.AskForNewSoundAlert.title
        alertMessage = Shared.AuthorDetail.AskForNewSoundAlert.message
        showAlert = true
    }
}
