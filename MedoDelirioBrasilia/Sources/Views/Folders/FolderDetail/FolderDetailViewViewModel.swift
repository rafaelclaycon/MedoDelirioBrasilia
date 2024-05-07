//
//  FolderDetailViewViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import Combine
import SwiftUI

class FolderDetailViewViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var sounds = [Sound]()

    @Published var soundSortOption: Int = FolderSoundSortOption.titleAscending.rawValue

    @Published var selectedSound: Sound? = nil
    @Published var selectedSounds: [Sound]? = nil
    @Published var nowPlayingKeeper = Set<String>()
    @Published var selectionKeeper = Set<String>()
    
    // Playlist
    @Published var isPlayingPlaylist: Bool = false
    private var currentTrackIndex: Int = 0
    
    // Sharing
    @Published var iPadShareSheet = ActivityViewController(activityItems: [URL(string: "https://www.apple.com")!])
    @Published var isShowingShareSheet: Bool = false
    @Published var shareBannerMessage: String = .empty
    @Published var displaySharedSuccessfullyToast: Bool = false
    
    // Alerts
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    @Published var alertType: FolderDetailAlertType = .ok

    // MARK: - Stored Properties

    private let folder: UserFolder

    // MARK: - Computed Properties

    var soundsPublisher: AnyPublisher<[Sound], Never> {
        $sounds.eraseToAnyPublisher()
    }

    // MARK: - Initializers

    init(
        folder: UserFolder
    ) {
        self.folder = folder
    }

    // MARK: - Functions

    func reloadSounds() {
        do {
            let folderContents = try LocalDatabase.shared.getAllContentsInsideUserFolder(withId: folder.id)
            let contentIds = folderContents.map { $0.contentId }
            self.sounds = try LocalDatabase.shared.sounds(withIds: contentIds)

            for i in stride(from: 0, to: self.sounds.count, by: 1) {
                // DateAdded here is date added to folder not to the app as it means outside folders.
                self.sounds[i].dateAdded = folderContents.first(where: { $0.contentId == self.sounds[i].id })?.dateAdded
            }

            guard sounds.count > 0 else { return }
            let sortOption = FolderSoundSortOption(rawValue: folder.userSortPreference ?? 0) ?? .titleAscending
            sort(&sounds, by: sortOption)
        } catch {
            print("Erro carregando sons: \(error.localizedDescription)")
        }
    }

    // MARK: - List Sorting

    func sort(_ sounds: inout [Sound], by sortOption: FolderSoundSortOption) {
        switch sortOption {
        case .titleAscending:
            sortByTitleAscending(&sounds)
        case .authorNameAscending:
            sortByAuthorNameAscending(&sounds)
        case .dateAddedDescending:
            sortByDateAddedDescending(&sounds)
        }
    }

    private func sortByTitleAscending(_ sounds: inout [Sound]) {
        sounds.sort(by: { $0.title.withoutDiacritics() < $1.title.withoutDiacritics() })
    }
    
    private func sortByAuthorNameAscending(_ sounds: inout [Sound]) {
        sounds.sort(by: { $0.authorName?.withoutDiacritics() ?? "" < $1.authorName?.withoutDiacritics() ?? "" })
    }
    
    private func sortByDateAddedDescending(_ sounds: inout [Sound]) {
        sounds.sort(by: { $0.dateAdded ?? Date() > $1.dateAdded ?? Date() })
    }

    // MARK: - Rest

    func getSoundCount() -> String {
        if sounds.count == 1 {
            return "1 SOM"
        } else {
            return "\(sounds.count) SONS"
        }
    }
}

// MARK: - Playlist

extension FolderDetailViewViewModel {

    func playAllSoundsOneAfterTheOther() {
        guard let firstSound = sounds.first else { return }
        isPlayingPlaylist = true
        // play(firstSound)
    }

    func playFrom(sound: Sound) {
        guard let soundIndex = sounds.firstIndex(where: { $0.id == sound.id }) else { return }
        let soundInArray = sounds[soundIndex]
        currentTrackIndex = soundIndex
        isPlayingPlaylist = true
        // play(soundInArray)
    }

    func doPlaylistCleanup() {
        currentTrackIndex = 0
        isPlayingPlaylist = false
    }
}

// MARK: - Alerts

extension FolderDetailViewViewModel {

    func showUnableToGetSoundAlert(_ soundTitle: String) {
        TapticFeedback.error()
        alertTitle = Shared.contentNotFoundAlertTitle(soundTitle)
        alertMessage = Shared.soundNotFoundAlertMessage
        alertType = .ok
        showAlert = true
    }

    func showServerSoundNotAvailableAlert(_ soundTitle: String) {
        TapticFeedback.error()
        alertType = .ok
        alertTitle = Shared.contentNotFoundAlertTitle(soundTitle)
        alertMessage = Shared.serverContentNotAvailableMessage
        showAlert = true
    }

    func showSoundRemovalConfirmation(soundTitle: String) {
        alertTitle = "Remover \"\(soundTitle)\"?"
        alertMessage = "O som continuará disponível fora da pasta."
        alertType = .removeSingleSound
        showAlert = true
    }

    func showRemoveMultipleSoundsConfirmation() {
        alertTitle = "Remover os sons selecionados?"
        alertMessage = "Os sons continuarão disponíveis fora da pasta."
        alertType = .removeMultipleSounds
        showAlert = true
    }
}
