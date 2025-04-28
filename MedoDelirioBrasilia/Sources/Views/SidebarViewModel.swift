//
//  SidebarViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 26/09/22.
//

import Foundation

@Observable
class SidebarViewModel {

    var state: LoadingState<[UserFolder]> = .loading
    let userFolderRepository: UserFolderRepositoryProtocol

    init(userFolderRepository: UserFolderRepositoryProtocol) {
        self.userFolderRepository = userFolderRepository
    }

    public func onViewAppeared() async {
        await loadContent()
    }

    public func onFoldersChanged() async {
        await loadContent()
    }

    private func loadContent() async {
        state = .loading
        do {
            state = .loaded(try await userFolderRepository.allFolders())
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
