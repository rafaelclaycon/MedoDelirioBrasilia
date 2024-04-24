//
//  SoundListViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 13/04/24.
//

import Combine
import SwiftUI

class SoundListViewModel<T>: ObservableObject {

    @Published var state: LoadingState<Sound> = .loading
    @Published var menuOptions: [ContextMenuSection]
    @Published var needsRefreshAfterChange: Bool
    var reloadAction: (() -> Void)?

    @Published var favoritesKeeper = Set<String>()
    @Published var highlightKeeper = Set<String>()
    @Published var nowPlayingKeeper = Set<String>()
    @Published var selectionKeeper = Set<String>()

    @Published var selectedSound: Sound? = nil
    @Published var selectedSounds: [Sound]? = nil
    @Published var subviewToOpen: SoundListModalToOpen = .shareAsVideo
    @Published var showingModalView = false

    // Share as Video
    @Published var shareAsVideoResult = ShareAsVideoResult()

    // Add to Folder vars
    @Published var hadSuccessAddingToFolder: Bool = false
    @Published var folderName: String? = nil
    @Published var pluralization: WordPluralization = .singular

    // Search
    @Published var searchText: String = ""

    // Sharing
    @Published var iPadShareSheet = ActivityViewController(activityItems: [URL(string: "https://www.apple.com")!])
    @Published var isShowingShareSheet: Bool = false
    @Published var shareBannerMessage: String = .empty

    // Select Many
    @Published var shareManyIsProcessing = false

    // Long Updates
    @Published var processedUpdateNumber: Int = 0
    @Published var totalUpdateCount: Int = 0

    // Alerts
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    @Published var alertType: AlertType = .singleOption

    // Toast
    @Published var showToastView: Bool = false
    @Published var toastIcon: String = "checkmark"
    @Published var toastIconColor: Color = .green
    @Published var toastText: String = ""

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initializer

    init(
        data: AnyPublisher<[Sound], Never>,
        menuOptions: [ContextMenuSection],
        needsRefreshAfterChange: Bool,
        reloadAction: (() -> Void)? = nil
    ) {
        self.menuOptions = menuOptions
        self.needsRefreshAfterChange = needsRefreshAfterChange
        self.reloadAction = reloadAction

        data
            .map { LoadingState.loaded($0) }
            .receive(on: DispatchQueue.main)
            .assign(to: &$state)
    }

    // MARK: - Functions

    func addToFavorites(soundId: String) {
        let newFavorite = Favorite(contentId: soundId, dateAdded: Date())

        do {
            let favorteAlreadyExists = try LocalDatabase.shared.exists(contentId: soundId)
            guard favorteAlreadyExists == false else { return }

            try LocalDatabase.shared.insert(favorite: newFavorite)
            favoritesKeeper.insert(newFavorite.contentId)
        } catch {
            print("Problem saving favorite \(newFavorite.contentId): \(error.localizedDescription)")
        }
    }

    func removeFromFavorites(soundId: String) {
        do {
            try LocalDatabase.shared.deleteFavorite(withId: soundId)
            favoritesKeeper.remove(soundId)
        } catch {
            print("Problem removing favorite \(soundId)")
        }
    }
}

// MARK: - Sound List Displaying Protocol Conformance

extension SoundListViewModel: SoundListDisplaying {

    func displayToast(
        _ toastIcon: String,
        _ toastIconColor: Color,
        toastText: String,
        displayTime: DispatchTimeInterval,
        completion: (() -> Void)?
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
            withAnimation {
                self.toastIcon = toastIcon
                self.toastIconColor = toastIconColor
                self.toastText = toastText
                self.showToastView = true
            }
            TapticFeedback.success()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + displayTime) {
            withAnimation {
                self.showToastView = false
                completion?()
            }
        }
    }

    func displayToast(toastText: String) {
        displayToast(
            "checkmark",
            .green,
            toastText: toastText,
            displayTime: .seconds(3),
            completion: nil
        )
    }

    func showUnableToGetSoundAlert(_ soundTitle: String) {
        TapticFeedback.error()
        alertType = .twoOptions
        alertTitle = Shared.contentNotFoundAlertTitle(soundTitle)
        alertMessage = Shared.soundNotFoundAlertMessage
        showAlert = true
    }

    func openShareAsVideoModal(for sound: Sound) {
        selectedSound = sound
        subviewToOpen = .shareAsVideo
        showingModalView = true
    }

    func toggleFavorite(_ soundId: String) {
        if favoritesKeeper.contains(soundId) {
            removeFromFavorites(soundId: soundId)
            if needsRefreshAfterChange {
                reloadAction!()
            }
        } else {
            addToFavorites(soundId: soundId)
        }
    }
}
