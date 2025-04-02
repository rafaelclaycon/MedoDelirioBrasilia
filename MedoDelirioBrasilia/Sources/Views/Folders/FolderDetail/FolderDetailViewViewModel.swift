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

    @Published var content = [AnyEquatableMedoContent]()
    @Published var soundSortOption: Int = FolderSoundSortOption.titleAscending.rawValue

    @Published var dataLoadingDidFail: Bool = false

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
    private let database: LocalDatabaseProtocol

    // MARK: - Computed Properties

    var soundsPublisher: AnyPublisher<[AnyEquatableMedoContent], Never> {
        $content
            .map { $0.map { AnyEquatableMedoContent($0) } }
            .eraseToAnyPublisher()
    }

    var soundCount: String {
        guard !content.isEmpty else { return "" }
        return content.count == 1 ? "1 ITEM" : "\(content.count) ITENS"
    }

    // MARK: - Initializers

    init(
        folder: UserFolder,
        database injectedDatabase: LocalDatabaseProtocol
    ) {
        self.folder = folder
        self.database = injectedDatabase
    }
}

// MARK: - User Actions

extension FolderDetailViewViewModel {

    public func onViewAppeared() {
        loadContent()
    }

    public func onPulledToRefresh() {
        loadContent()
    }

    public func onContentSortOptionChanged() {
        sortSounds(by: soundSortOption)
    }
}

// MARK: - Internal Functions

extension FolderDetailViewViewModel {

    private func loadContent() {
        do {
            let folderContents = try database.contentsInside(userFolder: folder.id)
            let contentIds = folderContents.map { $0.contentId }
            let sounds = try database.sounds(withIds: contentIds).map { AnyEquatableMedoContent($0) }
            let songs = try database.songs(withIds: contentIds).map { AnyEquatableMedoContent($0) }
            content = sounds + songs

            for i in stride(from: 0, to: self.content.count, by: 1) {
                // DateAdded here is date added to folder not to the app as it means outside folders.
                self.content[i].dateAdded = folderContents.first(where: { $0.contentId == self.content[i].id })?.dateAdded
            }

            guard content.count > 0 else { return }
            let sortOption = FolderSoundSortOption(rawValue: folder.userSortPreference ?? 0) ?? .titleAscending
            sort(&content, by: sortOption)
        } catch {
            print("Erro carregando sons: \(error.localizedDescription)")
        }
    }

    // MARK: - List Sorting

    private func sortSounds(by rawSortOption: Int) {
        let sortOption = FolderSoundSortOption(rawValue: rawSortOption) ?? .titleAscending
        sort(&content, by: sortOption)
        do {
            try database.update(userSortPreference: soundSortOption, forFolderId: folder.id)
        } catch {
            print("Erro ao salvar preferência de ordenação da pasta \(folder.name): \(error.localizedDescription)")
        }
    }

    private func sort(_ content: inout [AnyEquatableMedoContent], by sortOption: FolderSoundSortOption) {
        switch sortOption {
        case .titleAscending:
            sortByTitleAscending(&content)
        case .authorNameAscending:
            sortByAuthorNameAscending(&content)
        case .dateAddedDescending:
            sortByDateAddedDescending(&content)
        }
    }

    private func sortByTitleAscending(_ content: inout [AnyEquatableMedoContent]) {
        content.sort(by: { $0.title.withoutDiacritics() < $1.title.withoutDiacritics() })
    }

    private func sortByAuthorNameAscending(_ content: inout [AnyEquatableMedoContent]) {
        content.sort(by: { $0.subtitle.withoutDiacritics() < $1.subtitle.withoutDiacritics() })
    }

    private func sortByDateAddedDescending(_ content: inout [AnyEquatableMedoContent]) {
        content.sort(by: { $0.dateAdded ?? Date() > $1.dateAdded ?? Date() })
    }
}
