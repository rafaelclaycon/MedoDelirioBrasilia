//
//  AuthorsDetailView+ViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 19/05/22.
//

import Combine
import SwiftUI

extension AuthorDetailView {

    class ViewModel: ObservableObject {

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

        @State private var navBarTitle: String = .empty

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

        @Published var showingModalView = false

        // Add to Folder vars
        @Published var showingAddToFolderModal = false
        @Published var hadSuccessAddingToFolder: Bool = false
        @Published var folderName: String?
        @Published var pluralization: WordPluralization = .singular
        @Published var shouldDisplayAddedToFolderToast: Bool = false

        // Share as Video
        @Published var shareAsVideoResult = ShareAsVideoResult()

        @State private var showSelectionControlsInToolbar = false
        @State private var showMenuOnToolbarForiOS16AndHigher = false

        @State private var listWidth: CGFloat = 700
        @State private var columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]

        // MARK: - Static Properties

        let author: Author

        // MARK: - Computed Properties

        var edgesToIgnore: SwiftUI.Edge.Set {
            return author.photo == nil ? [] : .top
        }

        var isiOS15: Bool {
            if #available(iOS 16, *) {
                return false
            } else {
                return true
            }
        }

        var shouldDisplayMenuBesideAuthorName: Bool {
            !isiOS15
        }

        func getScrollOffset(_ geometry: GeometryProxy) -> CGFloat {
            geometry.frame(in: .global).minY
        }

        func getOffsetForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
            let offset = getScrollOffset(geometry)
            // Image was pulled down
            if offset > 0 {
                return -offset
            }
            return 0
        }

        func getHeightForHeaderImage(_ geometry: GeometryProxy) -> CGFloat {
            let offset = getScrollOffset(geometry)
            let imageHeight = geometry.size.height
            if offset > 0 {
                return imageHeight + offset
            }
            return imageHeight
        }

        func getOffsetBeforeShowingTitle() -> CGFloat {
            author.photo == nil ? 50 : 250
        }

        func updateNavBarContent(_ offset: CGFloat) {
            if offset < getOffsetBeforeShowingTitle() {
                DispatchQueue.main.async {
                    navBarTitle = title
                    showSelectionControlsInToolbar = currentSoundsListMode == .selection
                    showMenuOnToolbarForiOS16AndHigher = currentSoundsListMode == .regular
                }
            } else {
                DispatchQueue.main.async {
                    navBarTitle = .empty
                    showSelectionControlsInToolbar = false
                    showMenuOnToolbarForiOS16AndHigher = false
                }
            }
        }

        var title: String {
            guard currentSoundsListMode == .regular else {
                if selectionKeeper.count == 0 {
                    return Shared.SoundSelection.selectSounds
                } else if selectionKeeper.count == 1 {
                    return Shared.SoundSelection.soundSelectedSingular
                } else {
                    return String(format: Shared.SoundSelection.soundsSelectedPlural, selectionKeeper.count)
                }
            }
            return author.name
        }

        // MARK: - Initializers

        init(
            author: Author,
            currentSoundsListMode: Binding<SoundsListMode>
        ) {
            self.author = author
            self.currentSoundsListMode = currentSoundsListMode
            // Commented out to avoid growing the server db too large.
            // Sends metric only from iPhones because iPad and Mac are calling this methods twice instead of once upon each screen opening.
            /* if UIDevice.current.userInterfaceIdiom == .phone {
             sendUsageMetricToServer(originatingScreenName: originatingScreenName, authorName: authorName)
             } */
        }

        // MARK: - Functions

        func playOrSelect(sound: Sound, currentListMode: SoundsListMode) {
            if currentListMode == .regular {
                if nowPlayingKeeper.contains(sound.id) {
                    AudioPlayer.shared?.togglePlay()
                    nowPlayingKeeper.removeAll()
                } else {
                    play(sound)
                }
            } else {
                if selectionKeeper.contains(sound.id) {
                    selectionKeeper.remove(sound.id)
                } else {
                    selectionKeeper.insert(sound.id)
                }
            }
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

        func sortSoundsInPlaceByTitleAscending() {
            self.sounds.sort(by: { $0.title.withoutDiacritics() < $1.title.withoutDiacritics() })
        }

        func sortSoundsInPlaceByDateAddedDescending() {
            self.sounds.sort(by: { $0.dateAdded ?? Date() > $1.dateAdded ?? Date() })
        }

        func play(_ sound: Sound) {
            do {
                let url = try sound.fileURL()

                nowPlayingKeeper.removeAll()
                nowPlayingKeeper.insert(sound.id)

                AudioPlayer.shared = AudioPlayer(url: url, update: { [weak self] state in
                    guard let self = self else { return }
                    if state?.activity == .stopped {
                        self.nowPlayingKeeper.removeAll()
                    }
                })

                AudioPlayer.shared?.togglePlay()
            } catch {
                if sound.isFromServer ?? false {
                    showServerSoundNotAvailableAlert(sound.title)
                } else {
                    showUnableToGetSoundAlert(sound.title)
                }
            }
        }

        func stopPlaying() {
            if nowPlayingKeeper.count > 0 {
                AudioPlayer.shared?.togglePlay()
                nowPlayingKeeper.removeAll()
            }
        }

        func share(sound: Sound) {
            if UIDevice.current.userInterfaceIdiom == .phone {
                do {
                    try SharingUtility.shareSound(from: sound.fileURL(), andContentId: sound.id) { didShareSuccessfully in
                        if didShareSuccessfully {
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
                                withAnimation {
                                    self.shareBannerMessage = Shared.soundSharedSuccessfullyMessage
                                    self.displaySharedSuccessfullyToast = true
                                }
                                TapticFeedback.success()
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    self.displaySharedSuccessfullyToast = false
                                }
                            }
                        }
                    }
                } catch {
                    showUnableToGetSoundAlert(sound.title)
                }
            } else {
                do {
                    let url = try sound.fileURL()

                    iPadShareSheet = ActivityViewController(activityItems: [url]) { activity, completed, items, error in
                        if completed {
                            guard let activity = activity else {
                                return
                            }
                            let destination = ShareDestination.translateFrom(activityTypeRawValue: activity.rawValue)
                            Logger.shared.logSharedSound(contentId: sound.id, destination: destination, destinationBundleId: activity.rawValue)

                            AppStoreReviewSteward.requestReviewBasedOnVersionAndCount()

                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
                                withAnimation {
                                    self.shareBannerMessage = Shared.soundSharedSuccessfullyMessage
                                    self.displaySharedSuccessfullyToast = true
                                }
                                TapticFeedback.success()
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    self.displaySharedSuccessfullyToast = false
                                }
                            }
                        }
                    }
                } catch {
                    showUnableToGetSoundAlert(sound.title)
                }

                isShowingShareSheet = true
            }
        }

        func shareVideo(
            withPath filepath: String,
            andContentId contentId: String,
            title soundTitle: String
        ) {
            if UIDevice.current.userInterfaceIdiom == .phone {
                do {
                    try SharingUtility.shareVideoFromSound(withPath: filepath, andContentId: contentId, shareSheetDelayInSeconds: 0.6) { didShareSuccessfully in
                        if didShareSuccessfully {
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
                                withAnimation {
                                    self.shareBannerMessage = Shared.videoSharedSuccessfullyMessage
                                    self.displaySharedSuccessfullyToast = true
                                }
                                TapticFeedback.success()
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    self.displaySharedSuccessfullyToast = false
                                }
                            }
                        }

                        WallE.deleteAllVideoFilesFromDocumentsDir()
                    }
                } catch {
                    showUnableToGetSoundAlert(soundTitle)
                }
            } else {
                guard filepath.isEmpty == false else {
                    return
                }

                let url = URL(fileURLWithPath: filepath)

                iPadShareSheet = ActivityViewController(activityItems: [url]) { activity, completed, items, error in
                    if completed {
                        self.isShowingShareSheet = false

                        guard let activity = activity else {
                            return
                        }
                        let destination = ShareDestination.translateFrom(activityTypeRawValue: activity.rawValue)
                        Logger.shared.logSharedVideoFromSound(contentId: contentId, destination: destination, destinationBundleId: activity.rawValue)

                        AppStoreReviewSteward.requestReviewBasedOnVersionAndCount()

                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
                            withAnimation {
                                self.shareBannerMessage = Shared.videoSharedSuccessfullyMessage
                                self.displaySharedSuccessfullyToast = true
                            }
                            TapticFeedback.success()
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                self.displaySharedSuccessfullyToast = false
                            }
                        }
                    }

                    WallE.deleteAllVideoFilesFromDocumentsDir()
                }

                isShowingShareSheet = true
            }
        }

        func showVideoSavedSuccessfullyToast() {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
                withAnimation {
                    self.shareBannerMessage = ProcessInfo.processInfo.isiOSAppOnMac ? Shared.ShareAsVideo.videoSavedSucessfullyMac : Shared.ShareAsVideo.videoSavedSucessfully
                    self.displaySharedSuccessfullyToast = true
                }
                TapticFeedback.success()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    self.displaySharedSuccessfullyToast = false
                }
            }
        }

        func addToFavorites(soundId: String) {
            let newFavorite = Favorite(contentId: soundId, dateAdded: Date())

            do {
                try LocalDatabase.shared.insert(favorite: newFavorite)
                favoritesKeeper.insert(newFavorite.contentId)
            } catch {
                print("Problem saving favorite \(newFavorite.contentId)")
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

        func getSoundCount() -> String {
            if sounds.count == 1 {
                return "1 SOM"
            } else {
                return "\(sounds.count) SONS"
            }
        }

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

        func cancelSelectionAction() {
            currentSoundsListMode = .regular
            selectionKeeper.removeAll()
        }

        func favoriteAction() {
            // Need to get count before clearing the Set.
            let selectedCount: Int = selectionKeeper.count

            if allSelectedAreFavorites() {
                removeSelectedFromFavorites()
                stopSelecting()
                reloadList(
                    withSounds: try? LocalDatabase.shared.allSounds(forAuthor: author.id, isSensitiveContentAllowed: UserSettings.getShowExplicitContent()),
                    andFavorites: try? LocalDatabase.shared.favorites()
                )
                sendUsageMetricToServer(action: "didRemoveManySoundsFromFavorites(\(selectedCount))", authorName: author.name)
            } else {
                addSelectedToFavorites()
                stopSelecting()
                sendUsageMetricToServer(action: "didAddManySoundsToFavorites(\(selectedCount))", authorName: author.name)
            }
        }

        func addToFolderAction() {
            prepareSelectedToAddToFolder()
            showingAddToFolderModal = true
        }

        // MARK: - Multi-Select

        func startSelecting() {
            stopPlaying()
            if currentSoundsListMode.wrappedValue == .regular {
                currentSoundsListMode.wrappedValue = .selection
            } else {
                currentSoundsListMode.wrappedValue = .regular
                selectionKeeper.removeAll()
            }
        }

        func stopSelecting() {
            currentSoundsListMode.wrappedValue = .regular
            selectionKeeper.removeAll()
        }

        func addSelectedToFavorites() {
            guard selectionKeeper.count > 0 else { return }
            selectionKeeper.forEach { selectedSound in
                addToFavorites(soundId: selectedSound)
            }
        }

        func removeSelectedFromFavorites() {
            guard selectionKeeper.count > 0 else { return }
            selectionKeeper.forEach { selectedSound in
                removeFromFavorites(soundId: selectedSound)
            }
        }

        func allSelectedAreFavorites() -> Bool {
            guard selectionKeeper.count > 0 else { return false }
            return selectionKeeper.isSubset(of: favoritesKeeper)
        }

        func prepareSelectedToAddToFolder() {
            guard selectionKeeper.count > 0 else { return }
            selectedSounds = sounds.filter({ selectionKeeper.contains($0.id) })
        }

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

        // MARK: - Alerts

        func showUnableToGetSoundAlert(_ soundTitle: String) {
            TapticFeedback.error()
            alertType = .reportSoundIssue
            alertTitle = Shared.contentNotFoundAlertTitle(soundTitle)
            alertMessage = Shared.soundNotFoundAlertMessage
            showAlert = true
        }

        func showServerSoundNotAvailableAlert(_ soundTitle: String) {
            TapticFeedback.error()
            alertType = .reportSoundIssue
            alertTitle = Shared.contentNotFoundAlertTitle(soundTitle)
            alertMessage = Shared.serverContentNotAvailableMessage
            showAlert = true
        }

        func showAskForNewSoundAlert() {
            TapticFeedback.warning()
            alertType = .askForNewSound
            alertTitle = Shared.AuthorDetail.AskForNewSoundAlert.title
            alertMessage = Shared.AuthorDetail.AskForNewSoundAlert.message
            showAlert = true
        }
    }
}
