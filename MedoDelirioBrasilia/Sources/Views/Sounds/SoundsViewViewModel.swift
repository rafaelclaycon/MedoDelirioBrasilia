//
//  SoundsViewViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 19/05/22.
//

import Combine
import SwiftUI

@MainActor
class SoundsViewViewModel: ObservableObject, SyncManagerDelegate {

    @Published var sounds: [Sound] = []

    @Published var currentViewMode: SoundsViewMode
    @Published var soundSortOption: Int
    @Published var authorSortOption: Int

    @Published var favoritesKeeper = Set<String>()
    @Published var highlightKeeper = Set<String>()
    @Published var nowPlayingKeeper = Set<String>()
    @Published var selectionKeeper = Set<String>()
    @Published var showEmailAppPicker_soundUnavailableConfirmationDialog = false
    @Published var selectedSound: Sound? = nil
    @Published var selectedSounds: [Sound]? = nil
    var currentSoundsListMode: Binding<SoundsListMode>

    @Published var currentActivity: NSUserActivity? = nil

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

    // Sync
    private let syncManager: SyncManager
    private let syncValues: SyncValues

    // MARK: - Computed Properties

    private var displayLongUpdateBanner: Bool {
        totalUpdateCount >= 10 &&
        processedUpdateNumber != totalUpdateCount

    }

    init(
        currentViewMode: SoundsViewMode,
        soundSortOption: Int,
        authorSortOption: Int,
        currentSoundsListMode: Binding<SoundsListMode>,
        syncValues: SyncValues
    ) {
        self.currentViewMode = currentViewMode
        self.soundSortOption = soundSortOption
        self.authorSortOption = authorSortOption
        self.currentSoundsListMode = currentSoundsListMode

        self.syncManager = SyncManager(
            service: SyncService(
                connectionManager: ConnectionManager.shared,
                networkRabbit: NetworkRabbit.shared,
                localDatabase: LocalDatabase.shared
            ),
            database: LocalDatabase.shared,
            logger: Logger.shared
        )
        self.syncValues = syncValues
        self.syncManager.delegate = self
    }

    func reloadList(currentMode: SoundsViewMode) {
        guard currentMode == .allSounds || currentMode == .favorites else { return }

        do {
            sounds = try LocalDatabase.shared.sounds(
                allowSensitive: UserSettings.getShowExplicitContent(),
                favoritesOnly: currentMode == .favorites
            )

            guard sounds.count > 0 else { return }

            favoritesKeeper.removeAll()
            let favorites = try LocalDatabase.shared.favorites()
            if favorites.count > 0 {
                for favorite in favorites {
                    favoritesKeeper.insert(favorite.contentId)
                }
            }

            let sortOption: SoundSortOption = SoundSortOption(rawValue: UserSettings.getSoundSortOption()) ?? .dateAddedDescending
            sortSounds(by: sortOption)
        } catch {
            print("Erro")
        }
    }

    func sortSounds(by sortOption: SoundSortOption) {
        switch sortOption {
        case .titleAscending:
            sortSoundsInPlaceByTitleAscending()
        case .authorNameAscending:
            sortSoundsInPlaceByAuthorNameAscending()
        case .dateAddedDescending:
            sortSoundsInPlaceByDateAddedDescending()
        case .shortestFirst:
            sortSoundsInPlaceByDurationAscending()
        case .longestFirst:
            sortSoundsInPlaceByDurationDescending()
        case .longestTitleFirst:
            sortSoundsInPlaceByTitleLengthDescending()
        case .shortestTitleFirst:
            sortSoundsInPlaceByTitleLengthAscending()
        }
    }

    private func sortSoundsInPlaceByTitleAscending() {
        sounds.sort(by: { $0.title.withoutDiacritics() < $1.title.withoutDiacritics() })
    }

    private func sortSoundsInPlaceByAuthorNameAscending() {
        sounds.sort(by: { $0.authorName?.withoutDiacritics() ?? "" < $1.authorName?.withoutDiacritics() ?? "" })
    }

    private func sortSoundsInPlaceByDateAddedDescending() {
        sounds.sort(by: { $0.dateAdded ?? Date() > $1.dateAdded ?? Date() })
    }

    private func sortSoundsInPlaceByDurationAscending() {
        sounds.sort(by: { $0.duration < $1.duration })
    }

    private func sortSoundsInPlaceByDurationDescending() {
        sounds.sort(by: { $0.duration > $1.duration })
    }

    private func sortSoundsInPlaceByTitleLengthAscending() {
        sounds.sort(by: { $0.title.count < $1.title.count })
    }

    private func sortSoundsInPlaceByTitleLengthDescending() {
        sounds.sort(by: { $0.title.count > $1.title.count })
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
                showServerSoundNotAvailableAlert(sound)
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
                        self.displayToast(toastText: Shared.soundSharedSuccessfullyMessage)
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
                        self.isShowingShareSheet = false

                        guard let activity = activity else {
                            return
                        }
                        let destination = ShareDestination.translateFrom(activityTypeRawValue: activity.rawValue)
                        Logger.shared.logSharedSound(contentId: sound.id, destination: destination, destinationBundleId: activity.rawValue)

                        AppStoreReviewSteward.requestReviewBasedOnVersionAndCount()

                        self.displayToast(toastText: Shared.soundSharedSuccessfullyMessage)
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
                        self.displayToast(toastText: Shared.videoSharedSuccessfullyMessage)
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
                    
                    self.displayToast(toastText: Shared.videoSharedSuccessfullyMessage)
                }
                
                WallE.deleteAllVideoFilesFromDocumentsDir()
            }
            
            isShowingShareSheet = true
        }
    }
    
    func showVideoSavedSuccessfullyToast() {
        self.displayToast(toastText: ProcessInfo.processInfo.isiOSAppOnMac ? Shared.ShareAsVideo.videoSavedSucessfullyMac : Shared.ShareAsVideo.videoSavedSucessfully)
    }
    
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
        selectedSounds = nil
        searchText = ""
    }

    func addRemoveManyFromFavorites() {
        // Need to get count before clearing the Set.
        let selectedCount: Int = selectionKeeper.count

        if currentViewMode == .favorites || allSelectedAreFavorites() {
            removeSelectedFromFavorites()
            stopSelecting()
            reloadList(currentMode: currentViewMode)
            Analytics.sendUsageMetricToServer(
                originatingScreen: "SoundsView",
                action: "didRemoveManySoundsFromFavorites(\(selectedCount))"
            )
        } else {
            addSelectedToFavorites()
            stopSelecting()
            Analytics.sendUsageMetricToServer(
                originatingScreen: "SoundsView",
                action: "didAddManySoundsToFavorites(\(selectedCount))"
            )
        }
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
    
    func shareSelected() {
        guard selectionKeeper.count > 0 else { return }

        shareManyIsProcessing = true

        selectedSounds = sounds.filter({ selectionKeeper.contains($0.id) })
        guard selectedSounds?.count ?? 0 > 0 else { return }

        let successfulMessage = selectedSounds!.count > 1 ? Shared.soundsExportedSuccessfullyMessage : Shared.soundExportedSuccessfullyMessage

        do {
            try SharingUtility.share(sounds: selectedSounds!) { didShareSuccessfully in
                self.shareManyIsProcessing = false
                self.stopSelecting()
                if didShareSuccessfully {
                    self.displayToast(toastText: successfulMessage)
                }
            }
        } catch SoundError.fileNotFound(let soundTitle) {
            shareManyIsProcessing = false
            stopSelecting()
            showUnableToGetSoundAlert(soundTitle)
        } catch {
            shareManyIsProcessing = false
            stopSelecting()
            showShareManyIssueAlert(error.localizedDescription)
        }
    }
    
    func sendUsageMetricToServer(action: String) {
        let usageMetric = UsageMetric(customInstallId: UIDevice.customInstallId,
                                      originatingScreen: "SoundsView",
                                      destinationScreen: action,
                                      systemName: UIDevice.current.systemName,
                                      isiOSAppOnMac: ProcessInfo.processInfo.isiOSAppOnMac,
                                      appVersion: Versioneer.appVersion,
                                      dateTime: Date.now.iso8601withFractionalSeconds,
                                      currentTimeZone: TimeZone.current.abbreviation() ?? .empty)
        NetworkRabbit.shared.post(usageMetric: usageMetric)
    }
    
    // MARK: - Other
    
    func donateActivity() {
        self.currentActivity = UserActivityWaiter.getDonatableActivity(withType: Shared.ActivityTypes.playAndShareSounds, andTitle: "Ouvir e compartilhar sons")
        self.currentActivity?.becomeCurrent()
    }
    
    func sendUserPersonalTrendsToServerIfEnabled() async {
        guard UserSettings.getEnableTrends() else {
            return
        }
        guard UserSettings.getEnableShareUserPersonalTrends() else {
            return
        }
        
        if let lastDate = AppPersistentMemory.getLastSendDateOfUserPersonalTrendsToServer() {
            if lastDate.onlyDate! < Date.now.onlyDate! {
                let result = await Podium.shared.sendShareCountStatsToServer()

                guard result == .successful || result == .noStatsToSend else {
                    return
                }
                AppPersistentMemory.setLastSendDateOfUserPersonalTrendsToServer(to: Date.now.onlyDate!)
            }
        } else {
            let result = await Podium.shared.sendShareCountStatsToServer()

            guard result == .successful || result == .noStatsToSend else {
                return
            }
            AppPersistentMemory.setLastSendDateOfUserPersonalTrendsToServer(to: Date.now.onlyDate!)
        }
    }

    // MARK: - Sync

    func sync(lastAttempt: String) async {
        print("lastAttempt: \(lastAttempt)")
        guard
            lastAttempt == "" ||
            (lastAttempt.iso8601withFractionalSeconds?.twoMinutesHavePassed ?? false)
        else {
            if syncValues.syncStatus == .updating {
                syncValues.syncStatus = .done
            }

            var message = "Aguarde \(lastAttempt.minutesAndSecondsFromNow) para atualizar novamente."
            if UserSettings.getShowUpdateDateOnUI() {
                message += " \(AppPersistentMemory.getLastUpdateDate())"
            }

            return displayToast(
                "clock.fill",
                .orange,
                toastText: message,
                displayTime: .seconds(UserSettings.getShowUpdateDateOnUI() ? 10 : 3)
            )
        }

        await syncManager.sync()

        print("SYNC EXECUTED")

        var message = syncValues.syncStatus.description
        if UserSettings.getShowUpdateDateOnUI() {
            message += " \(AppPersistentMemory.getLastUpdateDate())"
        }

        displayToast(
            syncValues.syncStatus == .done ? "checkmark" : "exclamationmark.triangle.fill",
            syncValues.syncStatus == .done ? .green : .orange,
            toastText: message,
            displayTime: .seconds(UserSettings.getShowUpdateDateOnUI() ? 10 : 3)
        )
    }

    nonisolated func set(totalUpdateCount: Int) {
        Task { @MainActor in
            self.totalUpdateCount = totalUpdateCount
        }
    }

    nonisolated func didProcessUpdate(number: Int) {
        Task { @MainActor in
            processedUpdateNumber = number
        }
    }

    nonisolated func didFinishUpdating(
        status: SyncUIStatus,
        updateSoundList: Bool
    ) {
        Task { @MainActor in
            self.syncValues.syncStatus = status

            if updateSoundList {
                reloadList(currentMode: currentViewMode)
            }
        }
        print(status)
    }

    func redownloadServerContent(withId contentId: String) {
        Task {
            do {
                try await SyncService.downloadFile(contentId)
                displayToast(
                    "checkmark",
                    .green,
                    toastText: "Conteúdo baixado com sucesso. Tente tocá-lo novamente."
                )
            } catch {
                displayToast(
                    "exclamationmark.triangle.fill",
                    .orange,
                    toastText: "Erro ao tentar baixar conteúdo novamente."
                )
            }
        }
    }

    // MARK: - Alerts
    
    func showUnableToGetSoundAlert(_ soundTitle: String) {
        TapticFeedback.error()
        alertType = .twoOptions
        alertTitle = Shared.contentNotFoundAlertTitle(soundTitle)
        alertMessage = Shared.soundNotFoundAlertMessage
        showAlert = true
    }
    
    func showServerSoundNotAvailableAlert(_ sound: Sound) {
        selectedSound = sound
        TapticFeedback.error()
        alertType = .twoOptionsOneRedownload
        alertTitle = Shared.contentNotFoundAlertTitle(sound.title)
        alertMessage = Shared.serverContentNotAvailableRedownloadMessage
        showAlert = true
    }

    func showShareManyAlert() {
        let messageDisplayCount = AppPersistentMemory.getShareManyMessageShowCount()

        guard messageDisplayCount < 2 else { return shareSelected() }

        var timesMessage = ""
        if messageDisplayCount == 0 {
            timesMessage = "2 vezes"
        } else {
            timesMessage = "1 vez"
        }

        TapticFeedback.warning()
        alertType = .twoOptionsOneContinue
        alertTitle = "Incompatível com o WhatsApp"
        alertMessage = "Devido a um problema técnico, o WhatsApp recebe apenas o primeiro som selecionado. Use essa função para Salvar em Arquivos ou com o Telegram.\n\nEssa mensagem será mostrada mais \(timesMessage)."
        showAlert = true
    }

    func showShareManyIssueAlert(_ localizedError: String) {
        TapticFeedback.error()
        alertType = .singleOption
        alertTitle = "Problema ao Tentar Exportar Vários Sons"
        alertMessage = "Houve um problema desconhecido ao tentar compartilhar vários sons. Por favor, envie um print desse erro para o desenvolvedor (e-mail nas Configurações):\n\n\(localizedError)"
        showAlert = true
    }

    func showMoveDatabaseIssueAlert() {
        TapticFeedback.error()
        alertType = .singleOption
        alertTitle = "Problema ao Mover o Banco de Dados"
        alertMessage = "Houve um problema ao tentar mover o banco de dados do app. Por favor, envie um print desse erro para o desenvolvedor (e-mail nas Configurações):\n\n\(moveDatabaseIssue)"
        showAlert = true
    }

    // MARK: - Toast

    func displayToast(
        _ toastIcon: String = "checkmark",
        _ toastIconColor: Color = .green,
        toastText: String,
        displayTime: DispatchTimeInterval = .seconds(3),
        completion: (() -> Void)? = nil
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
}
