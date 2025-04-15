//
//  ContentGridViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 13/04/24.
//

import Combine
import SwiftUI

@MainActor
final class ContentGridViewModel<T>: ObservableObject {

    @Published var state: LoadingState<[AnyEquatableMedoContent]> = .loading
    @Published var menuOptions: [ContextMenuSection]
    @Published var needsRefreshAfterChange: Bool
    var refreshAction: (() -> Void)?
    var folder: UserFolder?

    @Published var favoritesKeeper = Set<String>()
    @Published var highlightKeeper = Set<String>()
    @Published var nowPlayingKeeper = Set<String>()
    @Published var selectionKeeper = Set<String>()

    @Published var selectedContentSingle: AnyEquatableMedoContent? = nil
    @Published var selectedContentMultiple: [AnyEquatableMedoContent]? = nil
    @Published var subviewToOpen: ContentListModalToOpen = .shareAsVideo
    @Published var showingModalView = false

    @Published var authorToOpen: Author? = nil

    // Share as Video
    @Published var shareAsVideoResult = ShareAsVideoResult()

    // Search
    @Published var searchText: String = ""

    // Sharing
    @Published var iPadShareSheet = ActivityViewController(activityItems: [URL(string: "https://www.apple.com")!])
    @Published var isShowingShareSheet: Bool = false
    @Published var shareBannerMessage: String = .empty

    // Long Updates
    @Published var processedUpdateNumber: Int = 0
    @Published var totalUpdateCount: Int = 0

    // Playlist
    @Published var isPlayingPlaylist: Bool = false
    private var currentTrackIndex: Int = 0

    // Alerts
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    @Published var alertType: SoundListAlertType = .soundFileNotFound

    // Play Random Sound
    @Published var scrollTo: String = ""

    // MARK: - Stored Properties

    public var currentListMode: Binding<ContentListMode>
    public var toast: Binding<Toast?>
    public var floatingOptions: Binding<FloatingContentOptions?>
    private let multiSelectFolderOperation: FolderOperation

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initializer

    init(
        menuOptions: [ContextMenuSection],
        currentListMode: Binding<ContentListMode>,
        toast: Binding<Toast?>,
        floatingOptions: Binding<FloatingContentOptions?>,
        needsRefreshAfterChange: Bool = false,
        refreshAction: (() -> Void)? = nil,
        insideFolder: UserFolder? = nil,
        multiSelectFolderOperation: FolderOperation = .add
    ) {
        self.menuOptions = menuOptions
        self.currentListMode = currentListMode
        self.toast = toast
        self.floatingOptions = floatingOptions
        self.needsRefreshAfterChange = needsRefreshAfterChange
        self.refreshAction = refreshAction
        self.folder = insideFolder
        self.multiSelectFolderOperation = multiSelectFolderOperation

        loadFavorites()
    }
}

// MARK: - User Actions

extension ContentGridViewModel {

    public func onContentSelected(_ content: AnyEquatableMedoContent) {
        if currentListMode.wrappedValue == .regular {
            if nowPlayingKeeper.contains(content.id) {
                AudioPlayer.shared?.togglePlay()
                nowPlayingKeeper.removeAll()
                doPlaylistCleanup() // Needed because user tap a playing sound to stop playing a playlist.
            } else {
                doPlaylistCleanup() // Needed because user can be playing a playlist and decide to tap another sound.
                play(content)
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
    ) {
        // Need to get count before clearing the Set.
        let selectedCount: Int = selectionKeeper.count

        if currentListMode.wrappedValue == .selection {
            stopSelecting()
        }

        toast.wrappedValue = Toast(message: pluralization.getAddedToFolderToastText(folderName: folderName), type: .success)

        if pluralization == .plural {
            Analytics().send(
                originatingScreen: "SoundsView",
                action: "didAddManySoundsToFolder(\(selectedCount))"
            )
        }
    }

    public func onViewDisappeared() {
        if isPlayingPlaylist {
            stopPlaying()
        }
    }

    public func onPlayStopPlaylistSelected() {
        playStopPlaylist()
    }

    public func onEnterMultiSelectModeSelected() {
        startSelecting()
    }

    public func onExitMultiSelectModeSelected() {
        stopSelecting()
    }

    public func onShareManySelected() async {
        await shareSelected()
    }

    public func onAddRemoveManyFromFavoritesSelected() {
        addRemoveManyFromFavorites()
    }

    public func onAddRemoveManyFromFolderSelected(_ operation: FolderOperation) {
        if operation == .add {
            addManyToFolder()
        } else {
            showRemoveMultipleSoundsConfirmation()
        }
    }

    public func onDidExitShareAsVideoSheet() {
        if shareAsVideoResult.videoFilepath.isEmpty == false {
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

    public func onRemoveMultipleContentSelected() {
        removeManyFromFolder()
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
            let favorites = try LocalDatabase.shared.favorites()
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
            let favorteAlreadyExists = try LocalDatabase.shared.exists(contentId: contentId)
            guard favorteAlreadyExists == false else { return }

            try LocalDatabase.shared.insert(favorite: newFavorite)
            favoritesKeeper.insert(newFavorite.contentId)
        } catch {
            print("Issue saving Favorite '\(newFavorite.contentId)': \(error.localizedDescription)")
        }
    }

    private func removeFromFavorites(contentId: String) {
        do {
            try LocalDatabase.shared.deleteFavorite(withId: contentId)
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
        if UIDevice.current.userInterfaceIdiom == .phone {
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

    private func playStopPlaylist() {
        if floatingOptions.wrappedValue != nil {
            stopSelecting()
        }
        if isPlayingPlaylist {
            stopPlaying()
        } else {
            playAllSoundsOneAfterTheOther()
        }
    }

    private func play(
        _ content: AnyEquatableMedoContent,
        scrollToPlaying: Bool = false
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
                        scrollToPlaying: scrollToPlaying
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
        scrollToPlaying: Bool
    ) {
        guard playerState?.activity == .stopped else { return }

        nowPlayingKeeper.removeAll()

        guard case .loaded(let sounds) = state else { return }
        guard isPlayingPlaylist else { return }

        currentTrackIndex += 1
        if currentTrackIndex >= sounds.count {
            doPlaylistCleanup()
            return
        }

        play(sounds[currentTrackIndex], scrollToPlaying: scrollToPlaying)
    }

    private func stopPlaying() {
        if nowPlayingKeeper.count > 0 {
            AudioPlayer.shared?.togglePlay()
            nowPlayingKeeper.removeAll()
            doPlaylistCleanup()
        }
    }

    private func playAllSoundsOneAfterTheOther() {
        guard case .loaded(let sounds) = state else { return }
        guard let firstSound = sounds.first else { return }
        isPlayingPlaylist = true
        play(firstSound, scrollToPlaying: true)
    }

    private func doPlaylistCleanup() {
        currentTrackIndex = 0
        isPlayingPlaylist = false
    }

    public func scrollAndPlaySound(withId soundId: String) {
        guard case .loaded(let sounds) = state else { return }
        guard let sound = sounds.first(where: { $0.id == soundId }) else { return }
        scrollTo = sound.id
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400)) {
            self.play(sound)
        }
    }
}

// MARK: - ContextMenuOption Communication

extension ContentGridViewModel: ContentListDisplaying {

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

    func toggleFavorite(_ contentId: String) {
        if favoritesKeeper.contains(contentId) {
            removeFromFavorites(contentId: contentId)
            if needsRefreshAfterChange {
                refreshAction!()
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

    func playFrom(content: AnyEquatableMedoContent) {
        guard case .loaded(let loadedContent) = state else { return }
        guard let soundIndex = loadedContent.firstIndex(where: { $0.id == content.id }) else { return }
        // TODO: Figure this out later
//        let soundInArray = sounds[soundIndex]
//        currentTrackIndex = soundIndex
//        isPlayingPlaylist = true
//        play(soundInArray, scrollToPlaying: true)
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
        guard let author = try? LocalDatabase.shared.author(withId: authorId) else {
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

    private func startSelecting() {
        stopPlaying()
        if currentListMode.wrappedValue == .regular {
            currentListMode.wrappedValue = .selection
            floatingOptions.wrappedValue = FloatingContentOptions(
                areButtonsEnabled: false,
                allSelectedAreFavorites: false,
                folderOperation: .add,
                shareIsProcessing: false,
                favoriteAction: addRemoveManyFromFavorites,
                folderAction: {
                    if self.multiSelectFolderOperation == .add {
                        self.addManyToFolder()
                    } else {
                        self.showRemoveMultipleSoundsConfirmation()
                    }
                },
                shareAction: {
                    Task {
                        await self.shareSelected()
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

    private func extractLoadedContent() -> [AnyEquatableMedoContent]? {
        switch state {
        case .loaded(let content):
            return content
        default:
            return nil
        }
    }

    public func allSelectedAreFavorites() -> Bool {
        guard selectionKeeper.count > 0 else { return false }
        return selectionKeeper.isSubset(of: favoritesKeeper)
    }

    private func addRemoveManyFromFavorites() {
        // Need to get count before clearing the Set.
        let selectedCount: Int = selectionKeeper.count

        if /*currentViewMode == .favorites ||*/ allSelectedAreFavorites() {
            removeSelectedFromFavorites()
            stopSelecting()
            guard let refreshAction else { return }
            refreshAction()
            Analytics().send(
                originatingScreen: "SoundsView",
                action: "didRemoveManySoundsFromFavorites(\(selectedCount))"
            )
        } else {
            addSelectedToFavorites()
            stopSelecting()
            Analytics().send(
                originatingScreen: "SoundsView",
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

    private func addManyToFolder() {
        guard selectionKeeper.count > 0 else { return }
        guard let content = extractLoadedContent() else { return }
        selectedContentMultiple = content.filter { selectionKeeper.contains($0.id) }
        subviewToOpen = .addToFolder
        showingModalView = true
    }

    private func removeManyFromFolder() {
        guard let folder else { return }
        guard let refreshAction else { return }
        guard selectionKeeper.count > 0 else { return }

        // Need to get count before clearing the Set.
        let selectedCount: Int = selectionKeeper.count // For Analytics

        do {
            try selectionKeeper.forEach { selectedSoundId in
                try LocalDatabase.shared.deleteUserContentFromFolder(withId: folder.id, contentId: selectedSoundId)
            }

            // Need to update folder hash so SyncManager knows about the change on next sync.
            try UserFolderRepository().update(folder)

            selectionKeeper.removeAll()
            floatingOptions.wrappedValue = nil
            refreshAction()

            stopSelecting()
            Analytics().sendUsageMetricToServer(
                folderName: "\(folder.symbol) \(folder.name)",
                action: "didRemoveManySoundsFromFolder(\(selectedCount))"
            )
        } catch {
            showIssueRemovingContentFromFolderAlert(plural: true)
        }
    }

    private func shareSelected() async {
        guard selectionKeeper.count > 0 else { return }

        floatingOptions.wrappedValue?.shareIsProcessing = true

        guard let content = extractLoadedContent() else { return }
        selectedContentMultiple = content.filter({ selectionKeeper.contains($0.id) })
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
            try LocalDatabase.shared.deleteUserContentFromFolder(withId: folder.id, contentId: sound.id)

            // Need to update folder hash so SyncManager knows about the change on next sync.
            try UserFolderRepository().update(folder)

            refreshAction()
        } catch {
            showIssueRemovingContentFromFolderAlert()
        }
    }
}

// MARK: - Scroll To Id

extension ContentGridViewModel {

    public func cancelSearchAndHighlight(id soundId: String) {
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

extension ContentGridViewModel {

    private func showUnableToGetSoundAlert(_ soundTitle: String) {
        TapticFeedback.error()
        alertType = .issueSharingSound
        alertTitle = Shared.contentNotFoundAlertTitle(soundTitle)
        alertMessage = Shared.contentNotFoundAlertMessage
        showAlert = true
    }

    private func showServerSoundNotAvailableAlert(_ content: AnyEquatableMedoContent) {
        selectedContentSingle = content
        TapticFeedback.error()
        alertType = .soundFileNotFound
        alertTitle = Shared.contentNotFoundAlertTitle(content.title)
        alertMessage = Shared.serverContentNotAvailableRedownloadMessage
        showAlert = true
    }

    private func showShareManyIssueAlert(_ localizedError: String) {
        TapticFeedback.error()
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
