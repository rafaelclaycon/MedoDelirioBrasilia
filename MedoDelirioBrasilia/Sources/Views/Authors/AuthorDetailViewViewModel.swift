//
//  AuthorsDetailViewViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 19/05/22.
//

import Combine
import SwiftUI

class AuthorDetailViewViewModel: ObservableObject {

    @Published var sounds = [Sound]()
    
    @Published var soundSortOption: Int = 1
    @Published var favoritesKeeper = Set<String>()
    @Published var nowPlayingKeeper = Set<String>()
    @Published var selectionKeeper = Set<String>()
    @Published var selectedSound: Sound? = nil
    @Published var selectedSounds: [Sound]? = nil
    
    @Published var showEmailAppPicker_suggestOtherAuthorNameConfirmationDialog = false
    @Published var showEmailAppPicker_soundUnavailableConfirmationDialog = false
    @Published var showEmailAppPicker_askForNewSound = false
    @Published var showEmailAppPicker_reportAuthorDetailIssue = false
    var currentSoundsListMode: Binding<SoundsListMode>
    
    // Sharing
    @Published var iPadShareSheet = ActivityViewController(activityItems: [URL(string: "https://www.apple.com")!])
    @Published var isShowingShareSheet: Bool = false
    @Published var shareBannerMessage: String = .empty
    @Published var displaySharedSuccessfullyToast: Bool = false
    
    // Alerts
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    @Published var alertType: AuthorDetailAlertType = .ok

    // MARK: - Computed Properties

    var soundsPublisher: AnyPublisher<[Sound], Never> {
        $sounds.eraseToAnyPublisher()
    }

    var soundCount: String {
        sounds.count == 1 ? "1 SOM" : "\(sounds.count) SONS"
    }

    // MARK: - Initializer

    init(
        // originatingScreenName: String,
        authorName: String,
        currentSoundsListMode: Binding<SoundsListMode>
    ) {
        self.currentSoundsListMode = currentSoundsListMode
        // Commented out to avoid growing the server db too large.
        // Sends metric only from iPhones because iPad and Mac are calling this methods twice instead of once upon each screen opening.
        /* if UIDevice.current.userInterfaceIdiom == .phone {
            sendUsageMetricToServer(originatingScreenName: originatingScreenName, authorName: authorName)
        } */
    }

    func reloadList(
        withSounds allSounds: [Sound]?,
        andFavorites favorites: [Favorite]?
    ) {
        guard let allSounds else { return self.sounds = [Sound]() }

        self.sounds = allSounds

        // From here the sounds array is already set
        if self.sounds.count > 0 {
            // Populate Favorites Keeper to display favorite cells accordingly
            if let favorites, !favorites.isEmpty {
                favoritesKeeper = Set(favorites.map { $0.contentId })
            } else {
                favoritesKeeper.removeAll()
            }

            sortSoundsInPlaceByDateAddedDescending()
        }
    }

    // MARK: - List Sorting

    func sortSounds(by rawSortOption: Int) {
        if rawSortOption == 0 {
            sortSoundsInPlaceByTitleAscending()
        } else {
            sortSoundsInPlaceByDateAddedDescending()
        }
    }

    func sortSoundsInPlaceByTitleAscending() {
        self.sounds.sort(by: { $0.title.withoutDiacritics() < $1.title.withoutDiacritics() })
    }

    func sortSoundsInPlaceByDateAddedDescending() {
        self.sounds.sort(by: { $0.dateAdded ?? Date() > $1.dateAdded ?? Date() })
    }

    // MARK: - Functions

    /* private func sendUsageMetricToServer(originatingScreenName: String, authorName: String) {
        let usageMetric = UsageMetric(customInstallId: UIDevice.customInstallId,
                                      originatingScreen: originatingScreenName,
                                      destinationScreen: "\(Shared.ScreenNames.authorDetailView)(\(authorName))",
                                      systemName: UIDevice.current.systemName,
                                      isiOSAppOnMac: ProcessInfo.processInfo.isiOSAppOnMac,
                                      appVersion: Versioneer.appVersion,
                                      dateTime: Date.now.iso8601withFractionalSeconds,
                                      currentTimeZone: TimeZone.current.abbreviation() ?? .empty)
        NetworkRabbit.shared.post(usageMetric: usageMetric)
    } */

    func sendUsageMetricToServer(
        action: String,
        authorName: String
    ) {
        let usageMetric = UsageMetric(
            customInstallId: UIDevice.customInstallId,
            originatingScreen: "AuthorDetailView(\(authorName))",
            destinationScreen: action,
            systemName: UIDevice.current.systemName,
            isiOSAppOnMac: ProcessInfo.processInfo.isiOSAppOnMac,
            appVersion: Versioneer.appVersion,
            dateTime: Date.now.iso8601withFractionalSeconds,
            currentTimeZone: TimeZone.current.abbreviation() ?? ""
        )
        NetworkRabbit.shared.post(usageMetric: usageMetric)
    }
}

// MARK: - Alert

extension AuthorDetailViewViewModel {

//    func showUnableToGetSoundAlert(_ soundTitle: String) {
//        TapticFeedback.error()
//        alertType = .reportSoundIssue
//        alertTitle = Shared.contentNotFoundAlertTitle(soundTitle)
//        alertMessage = Shared.soundNotFoundAlertMessage
//        showAlert = true
//    }
//
//    func showServerSoundNotAvailableAlert(_ soundTitle: String) {
//        TapticFeedback.error()
//        alertType = .reportSoundIssue
//        alertTitle = Shared.contentNotFoundAlertTitle(soundTitle)
//        alertMessage = Shared.serverContentNotAvailableMessage
//        showAlert = true
//    }

    func showAskForNewSoundAlert() {
        TapticFeedback.warning()
        alertType = .askForNewSound
        alertTitle = Shared.AuthorDetail.AskForNewSoundAlert.title
        alertMessage = Shared.AuthorDetail.AskForNewSoundAlert.message
        showAlert = true
    }
}
