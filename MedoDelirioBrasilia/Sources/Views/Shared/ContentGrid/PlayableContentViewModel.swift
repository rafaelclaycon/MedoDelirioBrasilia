//
//  PlayableContentViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 09/05/25.
//

import SwiftUI

@MainActor
@Observable
final class PlayableContentViewModel {

    var menuOptions: [ContextMenuSection]

    var favoritesKeeper = Set<String>()
    var nowPlayingKeeper = Set<String>()

    var selectedContentSingle: AnyEquatableMedoContent? = nil
    var selectedContentMultiple: [AnyEquatableMedoContent]? = nil
    var subviewToOpen: ContentGridModalToOpen = .shareAsVideo
    var showingModalView = false

    var authorToOpen: Author? = nil

    // Share as Video
    var shareAsVideoResult = ShareAsVideoResult(videoFilepath: "", contentId: "", exportMethod: .shareSheet)

    // Sharing
    var iPadShareSheet = ActivityViewController(activityItems: [URL(string: "https://www.apple.com")!])
    var isShowingShareSheet: Bool = false
    var shareBannerMessage: String = ""

    // Alerts
    var alertTitle: String = ""
    var alertMessage: String = ""
    var showAlert: Bool = false
    var alertType: PlayableContentAlert = .contentFileNotFound

    // MARK: - Stored Properties

    public var toast: Binding<Toast?>
    public var floatingOptions: Binding<FloatingContentOptions?>
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
        toast: Binding<Toast?>,
        floatingOptions: Binding<FloatingContentOptions?>,
        analyticsService: AnalyticsServiceProtocol
    ) {
        self.contentRepository = contentRepository
        self.userFolderRepository = userFolderRepository
        self.analyticsService = analyticsService
        self.currentScreen = screen
        self.menuOptions = menuOptions
        self.toast = toast
        self.floatingOptions = floatingOptions

        loadFavorites()
    }
}

// MARK: - User Actions

extension PlayableContentViewModel {

    public func onViewAppeared() {
        loadFavorites()
    }

    public func onContentSelected(
        _ content: AnyEquatableMedoContent,
        loadedContent: [AnyEquatableMedoContent]
    ) {
        if nowPlayingKeeper.contains(content.id) {
            AudioPlayer.shared?.togglePlay()
            nowPlayingKeeper.removeAll()
            //doPlaylistCleanup() // Needed because user tap a playing sound to stop playing a playlist.
        } else {
            //doPlaylistCleanup() // Needed because user can be playing a playlist and decide to tap another sound.
            play(content, loadedContent: loadedContent)
        }
    }

    public func onAddedContentToFolderSuccessfully(
        folderName: String,
        pluralization: WordPluralization
    ) async {
        // Need to get count before clearing the Set.
        let selectedCount: Int = 1

        toast.wrappedValue = Toast(message: pluralization.getAddedToFolderToastText(folderName: folderName), type: .success)

        if pluralization == .plural {
            await analyticsService.send(
                originatingScreen: currentScreen.rawValue,
                action: "didAddManySoundsToFolder(\(selectedCount))"
            )
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
        // subviewToOpen = .soundIssueEmailPicker // TODO: Fix this
        showingModalView = true
    }
}

// MARK: - Internal Functions

extension PlayableContentViewModel {

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

extension PlayableContentViewModel {

    private func play(
        _ content: AnyEquatableMedoContent,
        scrollToPlaying: Bool = false,
        loadedContent: [AnyEquatableMedoContent]
    ) {
        do {
            let url = try content.fileURL()

            nowPlayingKeeper.removeAll()
            nowPlayingKeeper.insert(content.id)

//            if scrollToPlaying {
//                scrollTo = content.id
//            }

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
//        guard isPlayingPlaylist else { return }
//
//        currentTrackIndex += 1
//        if currentTrackIndex >= loadedContent.count {
//            doPlaylistCleanup()
//            return
//        }
//
//        play(loadedContent[currentTrackIndex], scrollToPlaying: scrollToPlaying, loadedContent: loadedContent)
    }
}

// MARK: - ContextMenuOption Communication

extension PlayableContentViewModel: ContentGridDisplaying {

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
//        guard let index = loadedContent.firstIndex(where: { $0.id == content.id }) else { return }
//        let soundInArray = loadedContent[index]
//        currentTrackIndex = index
//        isPlayingPlaylist = true
//        play(soundInArray, scrollToPlaying: true, loadedContent: loadedContent)
    }

    func removeFromFolder(_ content: AnyEquatableMedoContent) {
//        selectedContentSingle = content
//        showSoundRemovalConfirmation(soundTitle: content.title)
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
        // subviewToOpen = .authorIssueEmailPicker(content) // TODO: Fix this
        showingModalView = true
    }
}

// MARK: - Alerts

extension PlayableContentViewModel {

    private func showUnableToGetSoundAlert(_ soundTitle: String) {
        HapticFeedback.error()
        alertType = .issueSharingContent
        alertTitle = Shared.contentNotFoundAlertTitle(soundTitle)
        alertMessage = Shared.contentNotFoundAlertMessage
        showAlert = true
    }

    private func showServerSoundNotAvailableAlert(_ content: AnyEquatableMedoContent) {
        selectedContentSingle = content
        HapticFeedback.error()
        alertType = .contentFileNotFound
        alertTitle = Shared.contentNotFoundAlertTitle(content.title)
        alertMessage = Shared.serverContentNotAvailableRedownloadMessage
        showAlert = true
    }

    private func showUnableToRedownloadSoundAlert() {
        alertTitle = "Não Foi Possível Baixar o Conteúdo"
        alertMessage = "Tente novamente mais tarde."
        alertType = .unableToRedownloadContent
        showAlert = true
    }
}
