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
    var refreshAction: (() -> Void)?
    var folder: UserFolder?

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
    @Published var alertType: SoundListAlertType = .soundFileNotFound

    // Toast
    @Published var showToastView: Bool = false
    @Published var toastIcon: String = "checkmark"
    @Published var toastIconColor: Color = .green
    @Published var toastText: String = ""

    // MARK: - Stored Properties

    var currentSoundsListMode: Binding<SoundsListMode>

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initializer

    init(
        data: AnyPublisher<[Sound], Never>,
        menuOptions: [ContextMenuSection],
        currentSoundsListMode: Binding<SoundsListMode>,
        needsRefreshAfterChange: Bool = false,
        refreshAction: (() -> Void)? = nil,
        insideFolder: UserFolder? = nil
    ) {
        self.menuOptions = menuOptions
        self.currentSoundsListMode = currentSoundsListMode
        self.needsRefreshAfterChange = needsRefreshAfterChange
        self.refreshAction = refreshAction
        self.folder = insideFolder

        print("WILL SET DATA")

        data
            .map { LoadingState.loaded($0) }
            .receive(on: DispatchQueue.main)
            .assign(to: &$state)

        print("CURRENT STATE AFTER RECEIVE IS: \(state)")

        loadFavorites()
    }

    // MARK: - Functions

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
                // Disregarding the case of the sound not being in the Bundle as this is highly unlikely since the launch of the sync system.
            }
        }
    }

    func stopPlaying() {
        if nowPlayingKeeper.count > 0 {
            AudioPlayer.shared?.togglePlay()
            nowPlayingKeeper.removeAll()
        }
    }

    func loadFavorites() {
        do {
            let favorites = try LocalDatabase.shared.favorites()
            favoritesKeeper.removeAll()
            favorites.forEach { favorite in
                self.favoritesKeeper.insert(favorite.contentId)
            }
        } catch {
            print("Falha ao carregar favoritos: \(error.localizedDescription)")
        }
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

    func redownloadServerContent(withId contentId: String) {
        Task {
            do {
                try await SyncService.downloadFile(contentId)
                displayToast(
                    "checkmark",
                    .green,
                    toastText: "Conteúdo baixado com sucesso. Tente tocá-lo novamente.",
                    displayTime: .seconds(3),
                    completion: nil
                )
            } catch {
                showUnableToRedownloadSoundAlert()
            }
        }
    }

    func showVideoSavedSuccessfullyToast() {
        self.displayToast(
            toastText: UIDevice.isMac ? Shared.ShareAsVideo.videoSavedSucessfullyMac : Shared.ShareAsVideo.videoSavedSucessfully
        )
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
}

// MARK: - ContextMenuOption Communication

extension SoundListViewModel: SoundListDisplaying {

    func share(sound: Sound) {
        if UIDevice.isiPhone {
            do {
                try SharingUtility.shareSound(from: sound.fileURL(), andContentId: sound.id) { didShare in
                    if didShare {
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

    func openShareAsVideoModal(for sound: Sound) {
        selectedSound = sound
        subviewToOpen = .shareAsVideo
        showingModalView = true
    }

    func toggleFavorite(_ soundId: String) {
        if favoritesKeeper.contains(soundId) {
            removeFromFavorites(soundId: soundId)
            if needsRefreshAfterChange {
                refreshAction!()
            }
        } else {
            addToFavorites(soundId: soundId)
        }
    }

    func addToFolder(_ sound: Sound) {
        selectedSounds = [Sound]()
        selectedSounds?.append(sound)
        subviewToOpen = .addToFolder
        showingModalView = true
    }

    func playFrom(sound: Sound) {
//        guard let soundIndex = sounds.firstIndex(where: { $0.id == sound.id }) else { return }
//        let soundInArray = sounds[soundIndex]
//        currentTrackIndex = soundIndex
//        isPlayingPlaylist = true
//        play(soundInArray)
    }

    func removeFromFolder(_ sound: Sound) {
        selectedSound = sound
        // showSoundRemovalConfirmation(soundTitle: sound.title)
    }
}

// MARK: - Toast

extension SoundListViewModel {

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

    func displayToast(
        toastText: String,
        completion: (() -> Void)?
    ) {
        displayToast(
            "checkmark",
            .green,
            toastText: toastText,
            displayTime: .seconds(3),
            completion: completion
        )
    }
}

// MARK: - Multi-Selection

extension SoundListViewModel {

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

    private func extractSounds() -> [Sound]? {
        switch state {
        case .loaded(let sounds):
            return sounds
        default:
            return nil
        }
    }

    func allSelectedAreFavorites() -> Bool {
        guard selectionKeeper.count > 0 else { return false }
        return selectionKeeper.isSubset(of: favoritesKeeper)
    }

    func addRemoveManyFromFavorites() {
        // Need to get count before clearing the Set.
        let selectedCount: Int = selectionKeeper.count

        if /*currentViewMode == .favorites ||*/ allSelectedAreFavorites() {
            removeSelectedFromFavorites()
            stopSelecting()
            guard let refreshAction else { return }
            refreshAction()
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

    func addManyToFolder() {
        guard selectionKeeper.count > 0 else { return }
        guard let sounds = extractSounds() else { return }
        selectedSounds = sounds.filter({ selectionKeeper.contains($0.id) })
        subviewToOpen = .addToFolder
        showingModalView = true
    }

    func removeManyFromFolder() {
        guard let folder else { return }
        guard let refreshAction else { return }
        guard selectionKeeper.count > 0 else { return }

        // Need to get count before clearing the Set.
        let selectedCount: Int = selectionKeeper.count // For Analytics

        selectionKeeper.forEach { selectedSoundId in
            try? LocalDatabase.shared.deleteUserContentFromFolder(withId: folder.id, contentId: selectedSoundId)
        }
        selectionKeeper.removeAll()
        refreshAction()

        stopSelecting()
        Analytics.sendUsageMetricToServer(
            folderName: "\(folder.symbol) \(folder.name)",
            action: "didRemoveManySoundsFromFolder(\(selectedCount))"
        )
    }

    func shareSelected() {
        guard selectionKeeper.count > 0 else { return }

        shareManyIsProcessing = true

        guard let sounds = extractSounds() else { return }
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
}

// MARK: - Scroll To Id

extension SoundListViewModel {

    func cancelSearchAndHighlight(id soundId: String) {
        if !searchText.isEmpty {
            searchText = ""
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }

        highlightKeeper.insert(soundId)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            self.highlightKeeper.remove(soundId)
        }
    }
}

// MARK: - Alerts

extension SoundListViewModel {

    func showUnableToGetSoundAlert(_ soundTitle: String) {
        TapticFeedback.error()
        alertType = .issueSharingSound
        alertTitle = Shared.contentNotFoundAlertTitle(soundTitle)
        alertMessage = Shared.soundNotFoundAlertMessage
        showAlert = true
    }

    func showServerSoundNotAvailableAlert(_ sound: Sound) {
        selectedSound = sound
        TapticFeedback.error()
        alertType = .soundFileNotFound
        alertTitle = Shared.contentNotFoundAlertTitle(sound.title)
        alertMessage = Shared.serverContentNotAvailableRedownloadMessage
        showAlert = true
    }

    // From the before times when WhatApp didn't really support receiving many sounds through the system Share Sheet.
//    func showShareManyAlert() {
//        let messageDisplayCount = AppPersistentMemory.getShareManyMessageShowCount()
//
//        guard messageDisplayCount < 2 else { return shareSelected() }
//
//        var timesMessage = ""
//        if messageDisplayCount == 0 {
//            timesMessage = "2 vezes"
//        } else {
//            timesMessage = "1 vez"
//        }
//
//        TapticFeedback.warning()
//        alertType = .optionIncompatibleWithWhatsApp
//        alertTitle = "Incompatível com o WhatsApp"
//        alertMessage = "Devido a um problema técnico, o WhatsApp recebe apenas o primeiro som selecionado. Use essa função para Salvar em Arquivos ou com o Telegram.\n\nEssa mensagem será mostrada mais \(timesMessage)."
//        showAlert = true
//    }

    func showShareManyIssueAlert(_ localizedError: String) {
        TapticFeedback.error()
        alertType = .issueExportingManySounds
        alertTitle = "Problema ao Tentar Exportar Vários Sons"
        alertMessage = "Houve um problema desconhecido ao tentar compartilhar vários sons. Por favor, envie um print desse erro para o desenvolvedor (e-mail nas Configurações):\n\n\(localizedError)"
        showAlert = true
    }

    func showRemoveMultipleSoundsConfirmation() {
        alertTitle = "Remover os sons selecionados?"
        alertMessage = "Os sons continuarão disponíveis fora da pasta."
        alertType = .removeMultipleSounds
        showAlert = true
    }

    func showUnableToRedownloadSoundAlert() {
        alertTitle = "Não Foi Possível Baixar o Conteúdo"
        alertMessage = "Tente novamente mais tarde."
        alertType = .unableToRedownloadSound
        showAlert = true
    }
}
