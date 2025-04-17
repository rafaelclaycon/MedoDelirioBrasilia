//
//  FolderDetailViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import SwiftUI

@Observable
class FolderDetailViewModel {

    // MARK: - Published Properties

    var state: LoadingState<[AnyEquatableMedoContent]> = .loading

    var contentSortOption: Int = FolderSoundSortOption.dateAddedDescending.rawValue

    // Alerts
    var alertTitle: String = ""
    var alertMessage: String = ""
    var showAlert: Bool = false
    var alertType: FolderDetailAlertType = .ok

    // MARK: - Stored Properties

    private let folder: UserFolder
    private let contentRepository: ContentRepositoryProtocol

    // MARK: - Computed Properties

    var contentCount: Int {
        guard case .loaded(let content) = state else { return 0 }
        return content.count
    }

    var contentCountText: String {
        contentCount == 1 ? "1 ITEM" : "\(contentCount) ITENS"
    }

    // MARK: - Initializers

    init(
        folder: UserFolder,
        contentRepository: ContentRepositoryProtocol
    ) {
        self.folder = folder
        self.contentRepository = contentRepository
    }
}

// MARK: - User Actions

extension FolderDetailViewModel {

    public func onViewAppeared() {
        loadContent()
    }

    public func onPulledToRefresh() {
        loadContent()
    }

    public func onContentSortOptionChanged() {
        loadContent()
    }

    public func onContentWasRemovedFromFolder() {
        loadContent()
    }
}

// MARK: - Internal Functions

extension FolderDetailViewModel {

    private func loadContent() {
        state = .loading
        do {
            let allowSensitive = UserSettings().getShowExplicitContent()
            let sort = FolderSoundSortOption(rawValue: contentSortOption) ?? .dateAddedDescending
            state = .loaded(try contentRepository.content(in: folder.id, allowSensitive, sort))
        } catch {
            state = .error(error.localizedDescription)
            debugPrint(error)
        }
    }
}
