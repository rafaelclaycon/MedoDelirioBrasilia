//
//  ContentGridViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 13/04/24.
//

import SwiftUI

@MainActor
@Observable
final class ContentGridViewModel {

    var menuOptions: [ContextMenuSection]
    var refreshAction: (() -> Void)?
    var folder: UserFolder?

    var favoritesKeeper = Set<String>()
    var highlightKeeper = Set<String>()
    var nowPlayingKeeper = Set<String>()
    var selectionKeeper = Set<String>()

    var selectedContentSingle: AnyEquatableMedoContent? = nil
    var selectedContentMultiple: [AnyEquatableMedoContent]? = nil
    var subviewToOpen: ContentGridModalToOpen = .shareAsVideo
    var showingModalView = false

    var authorToOpen: Author? = nil

    // Share as Video
    var shareAsVideoResult = ShareAsVideoResult(videoFilepath: "", contentId: "", exportMethod: .shareSheet)

    // Search
    var searchText: String = ""

    // Sharing
    var iPadShareSheet = ActivityViewController(activityItems: [URL(string: "https://www.apple.com")!])
    var isShowingShareSheet: Bool = false
    var shareBannerMessage: String = ""

    // Long Updates
    var processedUpdateNumber: Int = 0
    var totalUpdateCount: Int = 0

    // Playlist
    var isPlayingPlaylist: Bool = false
    private var currentTrackIndex: Int = 0

    // Alerts
    var alertTitle: String = ""
    var alertMessage: String = ""
    var showAlert: Bool = false
    var alertType: SoundListAlertType = .soundFileNotFound

    // Play Random Sound
    var scrollTo: String = ""

    // MARK: - Stored Properties

    public var currentListMode: Binding<ContentGridMode>
    public var toast: Binding<Toast?>
    public var floatingOptions: Binding<FloatingContentOptions?>
    private let multiSelectFolderOperation: FolderOperation
    private let contentRepository: ContentRepositoryProtocol
    private let userFolderRepository: UserFolderRepositoryProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let currentScreen: ContentGridScreen

    // MARK: - Initializer

    init(
        contentRepository: ContentRepositoryProtocol,
        userFolderRepository: UserFolderRepositoryProtocol,
        screen: ContentGridScreen,
        menuOptions: [ContextMenuSection],
        currentListMode: Binding<ContentGridMode>,
        toast: Binding<Toast?>,
        floatingOptions: Binding<FloatingContentOptions?>,
        refreshAction: (() -> Void)? = nil,
        insideFolder: UserFolder? = nil,
        multiSelectFolderOperation: FolderOperation = .add,
        analyticsService: AnalyticsServiceProtocol
    ) {
        self.contentRepository = contentRepository
        self.userFolderRepository = userFolderRepository
        self.analyticsService = analyticsService
        self.currentScreen = screen
        self.menuOptions = menuOptions
        self.currentListMode = currentListMode
        self.toast = toast
        self.floatingOptions = floatingOptions
        self.refreshAction = refreshAction
        self.folder = insideFolder
        self.multiSelectFolderOperation = multiSelectFolderOperation

        loadFavorites()
    }
}

// MARK: - User Actions

extension ContentGridViewModel {

    public func onViewAppeared() {
        loadFavorites()
    }

    public func onContentSelected(
        _ content: AnyEquatableMedoContent,
        loadedContent: [AnyEquatableMedoContent]
    ) {
        if currentListMode.wrappedValue == .regular {
            if nowPlayingKeeper.contains(content.id) {
                AudioPlayer.shared?.togglePlay()
                nowPlayingKeeper.removeAll()
                doPlaylistCleanup() // Needed because user tap a playing sound to stop playing a playlist.
            } else {
                doPlaylistCleanup() // Needed because user can be playing a playlist and decide to tap another sound.
                play(content, loadedContent: loadedContent)
            }
        } else {
            if selectionKeeper.contains(content.id) {
                selectionKeeper.remove(content.id)
            } else {
                selectionKeeper.insert(content.id)
            }
        }
    }

    public func onAddedContentToFolderSuccessfully(
        folderName: String,
        pluralization: WordPluralization
    ) async {
        // Need to get count before clearing the Set.
        let selectedCount: Int = selectionKeeper.count

        if currentListMode.wrappedValue == .selection {
            stopSelecting()
        }

        toast.wrappedValue = Toast(message: pluralization.getAddedToFolderToastText(folderName: folderName), type: .success)

        if pluralization == .plural {
            await analyticsService.send(
                originatingScreen: currentScreen.rawValue,
                action: "didAddManySoundsToFolder(\(selectedCount))"
            )
        }
    }

    public func onViewDisappeared() {
        if isPlayingPlaylist {
            stopPlaying()
        }
    }

    public func onPlayStopPlaylistSelected(loadedContent: [AnyEquatableMedoContent]) {
        playStopPlaylist(loadedContent: loadedContent)
    }

    public func onContentSortingChanged() {
        stopPlaying()
    }

    public func onEnterMultiSelectModeSelected(
        loadedContent: [AnyEquatableMedoContent],
        isFavoritesOnlyView: Bool
    ) {
        startSelecting(loadedContent: loadedContent, isFavoritesOnlyView: isFavoritesOnlyView)
    }

    public func onExitMultiSelectModeSelected() {
        stopSelecting()
    }

    public func onShareManySelected(loadedContent: [AnyEquatableMedoContent]) async {
        await shareSelected(loadedContent: loadedContent)
    }

    public func onAddRemoveManyFromFavoritesSelected(isFavoritesOnlyView: Bool) async {
        await addRemoveManyFromFavorites(isFavoritesOnlyView: isFavoritesOnlyView)
    }

    public func onAddRemoveManyFromFolderSelected(
        _ operation: FolderOperation,
        loadedContent: [AnyEquatableMedoContent]
    ) {
        if operation == .add {
            addManyToFolder(loadedContent: loadedContent)
        } else {
            showRemoveMultipleSoundsConfirmation()
        }
    }

    public func onDidExitShareAsVideoSheet() {
        if !shareAsVideoResult.videoFilepath.isEmpty {
            if shareAsVideoResult.exportMethod == .saveAsVideo {
                showVideoSavedSuccessfullyToast()
            } else {
                shareVideo(
                    withPath: shareAsVideoResult.videoFilepath,
                    andContentId: shareAsVideoResult.contentId,
                    title: selectedContentSingle?.title ?? ""
                )
            }
        }
    }

    public func onRedownloadContentOptionSelected() {
        guard let content = selectedContentSingle else { return }
        redownloadServerContent(withId: content.id)
    }

    public func onReportContentIssueSelected() {
        subviewToOpen = .soundIssueEmailPicker
        showingModalView = true
    }

    public func onRemoveSingleContentSelected() {
        removeSingleContentFromFolder()
    }

    public func onRemoveMultipleContentSelected() async {
        await removeManyFromFolder()
    }

    public func onItemSelectionChanged() {
        guard currentListMode.wrappedValue == .selection else { return }
        floatingOptions.wrappedValue?.areButtonsEnabled = selectionKeeper.count > 0
        floatingOptions.wrappedValue?.allSelectedAreFavorites = allSelectedAreFavorites()
    }
}

// MARK: - Internal Functions

extension ContentGridViewModel {

    private func loadFavorites() {
        do {
            let favorites = try contentRepository.favorites()
            favoritesKeeper.removeAll()
            favorites.forEach { favorite in
                self.favoritesKeeper.insert(favorite.contentId)
            }
        } catch {
            print("Falha ao carregar favoritos: \(error.localizedDescription)")
        }
    }

    private func addToFavorites(contentId: String) {
        let newFavorite = Favorite(contentId: contentId, dateAdded: Date())

        do {
            let favorteAlreadyExists = try contentRepository.favoriteExists(contentId)
            guard favorteAlreadyExists == false else { return }

            try contentRepository.insert(favorite: newFavorite)
            favoritesKeeper.insert(newFavorite.contentId)
        } catch {
            print("Issue saving Favorite '\(newFavorite.contentId)': \(error.localizedDescription)")
        }
    }

    private func removeFromFavorites(contentId: String) {
        do {
            try contentRepository.deleteFavorite(contentId)
            favoritesKeeper.remove(contentId)
        } catch {
            print("Issue removing Favorite '\(contentId)'.")
        }
    }

    private func redownloadServerContent(withId contentId: String) {
        Task {
            do {
                try await SyncService.downloadFile(contentId)
                toast.wrappedValue = Toast(
                    message: "Conteúdo baixado com sucesso. Tente tocá-lo novamente.",
                    type: .success
                )
            } catch {
                showUnableToRedownloadSoundAlert()
            }
        }
    }

    private func showVideoSavedSuccessfullyToast() {
        toast.wrappedValue = Toast(
            message: UIDevice.isMac ? Shared.ShareAsVideo.videoSavedSucessfullyMac : Shared.ShareAsVideo.videoSavedSucessfully,
            type: .success
        )
    }

    private func shareVideo(
        withPath filepath: String,
        andContentId contentId: String,
        title soundTitle: String
    ) {
        if UIDevice.isiPhone {
            do {
                try SharingUtility.share(
                    .videoFromSound,
                    withPath: filepath,
                    andContentId: contentId,
                    shareSheetDelayInSeconds: 0.6
                ) { didShareSuccessfully in
                    if didShareSuccessfully {
                        self.toast.wrappedValue = Toast(message: Shared.videoSharedSuccessfullyMessage, type: .success)
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
                    Logger.shared.logShared(
                        .videoFromSound,
                        contentId: contentId,
                        destination: destination,
                        destinationBundleId: activity.rawValue
                    )

                    AppStoreReviewSteward.requestReviewBasedOnVersionAndCount()

                    self.toast.wrappedValue = Toast(message: Shared.videoSharedSuccessfullyMessage, type: .success)
                }

                WallE.deleteAllVideoFilesFromDocumentsDir()
            }

            isShowingShareSheet = true
        }
    }

    public func typeForShareAsVideo() -> ContentType {
        guard let content = selectedContentSingle else {
            return .videoFromSound
        }
        return content.type == .sound ? .videoFromSound : .videoFromSong
    }
}

// MARK: - Sound Playback

extension ContentGridViewModel {

    private func playStopPlaylist(loadedContent: [AnyEquatableMedoContent]) {
        if floatingOptions.wrappedValue != nil {
            stopSelecting()
        }
        if isPlayingPlaylist {
            stopPlaying()
        } else {
            playAllOneAfterTheOther(loadedContent: loadedContent)
        }
    }

    private func play(
        _ content: AnyEquatableMedoContent,
        scrollToPlaying: Bool = false,
        loadedContent: [AnyEquatableMedoContent]
    ) {
        do {
            let url = try content.fileURL()

            nowPlayingKeeper.removeAll()
            nowPlayingKeeper.insert(content.id)

            if scrollToPlaying {
                scrollTo = content.id
            }

            AudioPlayer.shared = AudioPlayer(
                url: url,
                update: { [weak self] state in
                    self?.onAudioPlayerUpdate(
                        playerState: state,
                        scrollToPlaying: scrollToPlaying,
                        loadedContent: loadedContent
                    )
                }
            )

            AudioPlayer.shared?.togglePlay()
        } catch {
            if content.isFromServer ?? false {
                showServerSoundNotAvailableAlert(content)
                // Disregarding the case of the sound not being in the Bundle as this is highly unlikely since the launch of the sync system.
            }
        }
    }

    private func onAudioPlayerUpdate(
        playerState: AudioPlayer.State?,
        scrollToPlaying: Bool,
        loadedContent: [AnyEquatableMedoContent]
    ) {
        guard playerState?.activity == .stopped else { return }

        nowPlayingKeeper.removeAll()

        guard !loadedContent.isEmpty else { return }
        guard isPlayingPlaylist else { return }

        currentTrackIndex += 1
        if currentTrackIndex >= loadedContent.count {
            doPlaylistCleanup()
            return
        }

        play(loadedContent[currentTrackIndex], scrollToPlaying: scrollToPlaying, loadedContent: loadedContent)
    }

    private func stopPlaying() {
        if nowPlayingKeeper.count > 0 {
            AudioPlayer.shared?.togglePlay()
            nowPlayingKeeper.removeAll()
            doPlaylistCleanup()
        }
    }

    private func playAllOneAfterTheOther(loadedContent: [AnyEquatableMedoContent]) {
        guard let first = loadedContent.first else { return }
        isPlayingPlaylist = true
        play(first, scrollToPlaying: true, loadedContent: loadedContent)
    }

    private func doPlaylistCleanup() {
        currentTrackIndex = 0
        isPlayingPlaylist = false
    }

    public func scrollAndPlay(
        contentId: String,
        loadedContent: [AnyEquatableMedoContent]
    ) {
        guard let content = loadedContent.first(where: { $0.id == contentId }) else { return }
        scrollTo = content.id
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400)) {
            self.play(content, loadedContent: loadedContent)
        }
    }
}

// MARK: - ContextMenuOption Communication

extension ContentGridViewModel: ContentGridDisplaying {

    func share(content: AnyEquatableMedoContent) {
        if UIDevice.isiPhone {
            do {
                try SharingUtility.shareSound(
                    from: content.fileURL(),
                    andContentId: content.id,
                    context: .sound
                ) { didShare in
                    if didShare {
                        self.toast.wrappedValue = Toast(message: Shared.soundSharedSuccessfullyMessage, type: .success)
                    }
                }
            } catch {
                showUnableToGetSoundAlert(content.title)
            }
        } else {
            do {
                let url = try content.fileURL()
                iPadShareSheet = ActivityViewController(activityItems: [url]) { activity, completed, items, error in
                    if completed {
                        self.isShowingShareSheet = false

                        guard let activity = activity else {
                            return
                        }
                        let destination = ShareDestination.translateFrom(activityTypeRawValue: activity.rawValue)
                        Logger.shared.logShared(.sound, contentId: content.id, destination: destination, destinationBundleId: activity.rawValue)

                        AppStoreReviewSteward.requestReviewBasedOnVersionAndCount()

                        self.toast.wrappedValue = Toast(message: Shared.soundSharedSuccessfullyMessage, type: .success)
                    }
                }
            } catch {
                showUnableToGetSoundAlert(content.title)
            }

            isShowingShareSheet = true
        }
    }

    func openShareAsVideoModal(for content: AnyEquatableMedoContent) {
        selectedContentSingle = content
        subviewToOpen = .shareAsVideo
        showingModalView = true
    }

    func toggleFavorite(_ contentId: String, isFavoritesOnlyView: Bool) {
        if favoritesKeeper.contains(contentId) {
            removeFromFavorites(contentId: contentId)
            if isFavoritesOnlyView {
                refreshAction?()
            }
        } else {
            addToFavorites(contentId: contentId)
        }
    }

    func addToFolder(_ content: AnyEquatableMedoContent) {
        selectedContentMultiple = [AnyEquatableMedoContent]()
        selectedContentMultiple?.append(content)
        subviewToOpen = .addToFolder
        showingModalView = true
    }

    func playFrom(
        content: AnyEquatableMedoContent,
        loadedContent: [AnyEquatableMedoContent]
    ) {
        guard let index = loadedContent.firstIndex(where: { $0.id == content.id }) else { return }
        let soundInArray = loadedContent[index]
        currentTrackIndex = index
        isPlayingPlaylist = true
        play(soundInArray, scrollToPlaying: true, loadedContent: loadedContent)
    }

    func removeFromFolder(_ content: AnyEquatableMedoContent) {
        selectedContentSingle = content
        showSoundRemovalConfirmation(soundTitle: content.title)
    }

    func showDetails(for content: AnyEquatableMedoContent) {
        selectedContentSingle = content
        subviewToOpen = .contentDetail
        showingModalView = true
    }

    func showAuthor(withId authorId: String) {
        guard let author = try? contentRepository.author(withId: authorId) else {
            print("ContentGrid error: unable to find author with id \(authorId)")
            return
        }
        authorToOpen = author
    }

    func suggestOtherAuthorName(for content: AnyEquatableMedoContent) {
        subviewToOpen = .authorIssueEmailPicker(content)
        showingModalView = true
    }
}

// MARK: - Multi-Selection

extension ContentGridViewModel {

    private func startSelecting(
        loadedContent: [AnyEquatableMedoContent],
        isFavoritesOnlyView: Bool
    ) {
        stopPlaying()
        if currentListMode.wrappedValue == .regular {
            currentListMode.wrappedValue = .selection
            floatingOptions.wrappedValue = FloatingContentOptions(
                areButtonsEnabled: false,
                allSelectedAreFavorites: false,
                folderOperation: multiSelectFolderOperation,
                shareIsProcessing: false,
                favoriteAction: { Task { await self.addRemoveManyFromFavorites(isFavoritesOnlyView: isFavoritesOnlyView) } },
                folderAction: {
                    if self.multiSelectFolderOperation == .add {
                        self.addManyToFolder(loadedContent: loadedContent)
                    } else {
                        self.showRemoveMultipleSoundsConfirmation()
                    }
                },
                shareAction: {
                    Task {
                        await self.shareSelected(loadedContent: loadedContent)
                    }
                }
            )
        } else {
            currentListMode.wrappedValue = .regular
            selectionKeeper.removeAll()
            floatingOptions.wrappedValue = nil
        }
    }

    private func stopSelecting() {
        currentListMode.wrappedValue = .regular
        selectionKeeper.removeAll()
        selectedContentMultiple = nil
        searchText = ""
        floatingOptions.wrappedValue = nil
    }

    public func allSelectedAreFavorites() -> Bool {
        guard selectionKeeper.count > 0 else { return false }
        return selectionKeeper.isSubset(of: favoritesKeeper)
    }

    private func addRemoveManyFromFavorites(isFavoritesOnlyView: Bool) async {
        // Need to get count before clearing the Set.
        let selectedCount: Int = selectionKeeper.count

        if isFavoritesOnlyView || allSelectedAreFavorites() {
            removeSelectedFromFavorites()
            stopSelecting()
            if let refreshAction {
                refreshAction()
            }
            await analyticsService.send(
                originatingScreen: currentScreen.rawValue,
                action: "didRemoveManySoundsFromFavorites(\(selectedCount))"
            )
        } else {
            addSelectedToFavorites()
            stopSelecting()
            await analyticsService.send(
                originatingScreen: currentScreen.rawValue,
                action: "didAddManySoundsToFavorites(\(selectedCount))"
            )
        }
    }

    private func addSelectedToFavorites() {
        guard selectionKeeper.count > 0 else { return }
        selectionKeeper.forEach { selectedSound in
            addToFavorites(contentId: selectedSound)
        }
    }

    private func removeSelectedFromFavorites() {
        guard selectionKeeper.count > 0 else { return }
        selectionKeeper.forEach { selectedSound in
            removeFromFavorites(contentId: selectedSound)
        }
    }

    private func addManyToFolder(loadedContent: [AnyEquatableMedoContent]) {
        guard selectionKeeper.count > 0 else { return }
        selectedContentMultiple = loadedContent.filter { selectionKeeper.contains($0.id) }
        subviewToOpen = .addToFolder
        showingModalView = true
    }

    private func removeManyFromFolder() async {
        guard let folder else { return }
        guard let refreshAction else { return }
        guard selectionKeeper.count > 0 else { return }

        // Need to get count before clearing the Set.
        let selectedCount: Int = selectionKeeper.count // For Analytics

        do {
            try selectionKeeper.forEach { selectedSoundId in
                try userFolderRepository.deleteUserContentFromFolder(withId: folder.id, contentId: selectedSoundId)
            }

            // Need to update folder hash so SyncManager knows about the change on next sync.
            try userFolderRepository.update(folder)

            selectionKeeper.removeAll()
            floatingOptions.wrappedValue = nil
            refreshAction()

            stopSelecting()
            await analyticsService.send(
                currentScreen: currentScreen.rawValue,
                folderName: "\(folder.symbol) \(folder.name)",
                action: "didRemoveManySoundsFromFolder(\(selectedCount))"
            )
        } catch {
            showIssueRemovingContentFromFolderAlert(plural: true)
        }
    }

    private func shareSelected(loadedContent: [AnyEquatableMedoContent]) async {
        guard selectionKeeper.count > 0 else { return }

        floatingOptions.wrappedValue?.shareIsProcessing = true

        selectedContentMultiple = loadedContent.filter({ selectionKeeper.contains($0.id) })
        guard selectedContentMultiple?.count ?? 0 > 0 else { return }

        let successfulMessage = selectedContentMultiple!.count > 1 ? Shared.soundsExportedSuccessfullyMessage : Shared.soundExportedSuccessfullyMessage

        do {
            let hadSuccessSharing = try await SharingUtility.share(content: selectedContentMultiple!)
            floatingOptions.wrappedValue?.shareIsProcessing = false
            stopSelecting()
            if hadSuccessSharing {
                toast.wrappedValue = Toast(message: successfulMessage, type: .success)
            }
        } catch SoundError.fileNotFound(let soundTitle) {
            floatingOptions.wrappedValue?.shareIsProcessing = false
            stopSelecting()
            showUnableToGetSoundAlert(soundTitle)
        } catch {
            floatingOptions.wrappedValue?.shareIsProcessing = false
            stopSelecting()
            showShareManyIssueAlert(error.localizedDescription)
        }
    }
}

// MARK: - Folder

extension ContentGridViewModel {

    private func removeSingleContentFromFolder() {
        guard let folder else { return }
        guard let refreshAction else { return }
        guard let sound = selectedContentSingle else { return }

        do {
            try userFolderRepository.deleteUserContentFromFolder(withId: folder.id, contentId: sound.id)

            // Need to update folder hash so SyncManager knows about the change on next sync.
            try userFolderRepository.update(folder)

            refreshAction()
        } catch {
            showIssueRemovingContentFromFolderAlert()
        }
    }
}

// MARK: - Scroll To Id

extension ContentGridViewModel {

    public func cancelSearchAndHighlight(id contentId: String) {
        if !searchText.isEmpty {
            searchText = ""
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }

        highlightKeeper.insert(contentId)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            self.highlightKeeper.remove(contentId)
        }
    }
}

// MARK: - Alerts

extension ContentGridViewModel {

    private func showUnableToGetSoundAlert(_ soundTitle: String) {
        HapticFeedback.error()
        alertType = .issueSharingSound
        alertTitle = Shared.contentNotFoundAlertTitle(soundTitle)
        alertMessage = Shared.contentNotFoundAlertMessage
        showAlert = true
    }

    private func showServerSoundNotAvailableAlert(_ content: AnyEquatableMedoContent) {
        selectedContentSingle = content
        HapticFeedback.error()
        alertType = .soundFileNotFound
        alertTitle = Shared.contentNotFoundAlertTitle(content.title)
        alertMessage = Shared.serverContentNotAvailableRedownloadMessage
        showAlert = true
    }

    private func showShareManyIssueAlert(_ localizedError: String) {
        HapticFeedback.error()
        alertType = .issueExportingManySounds
        alertTitle = "Problema ao Tentar Exportar Vários Conteúdos"
        alertMessage = "Houve um problema desconhecido ao tentar compartilhar vários conteúdos. Por favor, envie um print desse erro para o desenvolvedor (e-mail nas Configurações):\n\n\(localizedError)"
        showAlert = true
    }

    private func showSoundRemovalConfirmation(soundTitle: String) {
        alertTitle = "Remover \"\(soundTitle)\"?"
        alertMessage = "O conteúdo continuará disponível fora da pasta."
        alertType = .removeSingleSound
        showAlert = true
    }

    private func showRemoveMultipleSoundsConfirmation() {
        alertTitle = "Remover os conteúdos selecionados?"
        alertMessage = "Os conteúdos continuarão disponíveis fora da pasta."
        alertType = .removeMultipleSounds
        showAlert = true
    }

    private func showUnableToRedownloadSoundAlert() {
        alertTitle = "Não Foi Possível Baixar o Conteúdo"
        alertMessage = "Tente novamente mais tarde."
        alertType = .unableToRedownloadSound
        showAlert = true
    }

    private func showIssueRemovingContentFromFolderAlert(plural: Bool = false) {
        alertTitle = "Não Foi Possível Remover \(plural ? "os Conteúdos" : "o Conteúdo") da Pasta"
        alertMessage = "Tente novamente mais tarde."
        alertType = .issueRemovingSoundFromFolder
        showAlert = true
    }
}
