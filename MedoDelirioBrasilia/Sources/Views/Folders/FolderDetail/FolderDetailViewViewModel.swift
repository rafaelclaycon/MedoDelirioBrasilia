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
    
    // Playlist
    @Published var isPlayingPlaylist: Bool = false
    private var currentTrackIndex: Int = 0
    
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

    var soundCount: String {
        sounds.count == 1 ? "1 SOM" : "\(sounds.count) SONS"
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

    func sortSounds(by rawSortOption: Int) {
        let sortOption = FolderSoundSortOption(rawValue: rawSortOption) ?? .titleAscending
        sort(&sounds, by: sortOption)
        do {
            try LocalDatabase.shared.update(userSortPreference: soundSortOption, forFolderId: folder.id)
        } catch {
            print("Erro ao salvar preferência de ordenação da pasta \(folder.name): \(error.localizedDescription)")
        }
    }

    private func sort(_ sounds: inout [Sound], by sortOption: FolderSoundSortOption) {
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
}
