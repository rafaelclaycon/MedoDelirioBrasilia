//
//  AuthorsDetailViewViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 19/05/22.
//

import Combine
import SwiftUI

class AuthorDetailViewModel: ObservableObject {

    @Published var sounds = [Sound]()

    @Published var dataLoadingDidFail: Bool = false

    @Published var soundSortOption: Int = 1
    @Published var selectedSound: Sound? = nil
    @Published var selectedSounds: [Sound]? = nil
    
    @Published var showEmailAppPicker_suggestOtherAuthorNameConfirmationDialog = false
    @Published var showEmailAppPicker_soundUnavailableConfirmationDialog = false
    @Published var showEmailAppPicker_askForNewSound = false
    @Published var showEmailAppPicker_reportAuthorDetailIssue = false
    var currentContentListMode: Binding<ContentListMode>

    // Alerts
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    @Published var alertType: AuthorDetailAlertType = .ok

    // MARK: - Computed Properties

    var soundsPublisher: AnyPublisher<[AnyEquatableMedoContent], Never> {
        $sounds
            .map { $0.map { AnyEquatableMedoContent($0) } }
            .eraseToAnyPublisher()
    }

    var soundCount: String {
        sounds.count == 1 ? "1 SOM" : "\(sounds.count) SONS"
    }

    // MARK: - Initializer

    init(
        currentContentListMode: Binding<ContentListMode>
    ) {
        self.currentContentListMode = currentContentListMode
    }

    func loadSounds(for authorId: String) {
        do {
            sounds = try LocalDatabase.shared.allSounds(
                forAuthor: authorId,
                isSensitiveContentAllowed: UserSettings().getShowExplicitContent()
            )
            guard sounds.count > 0 else { return }
            sortSounds(by: soundSortOption)
        } catch {
            print("Erro carregando sons: \(error.localizedDescription)")
            dataLoadingDidFail = true
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

    private func sortSoundsInPlaceByTitleAscending() {
        self.sounds.sort(by: { $0.title.withoutDiacritics() < $1.title.withoutDiacritics() })
    }

    private func sortSoundsInPlaceByDateAddedDescending() {
        self.sounds.sort(by: { $0.dateAdded ?? Date() > $1.dateAdded ?? Date() })
    }

    // MARK: - Functions

    func sendUsageMetricToServer(
        action: String,
        authorName: String
    ) {
        let usageMetric = UsageMetric(
            customInstallId: AppPersistentMemory().customInstallId,
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

extension AuthorDetailViewModel {

    func showAskForNewSoundAlert() {
        TapticFeedback.warning()
        alertType = .askForNewSound
        alertTitle = Shared.AuthorDetail.AskForNewSoundAlert.title
        alertMessage = Shared.AuthorDetail.AskForNewSoundAlert.message
        showAlert = true
    }
}
