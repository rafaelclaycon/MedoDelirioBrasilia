//
//  StandaloneFavoritesViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 12/04/25.
//

import SwiftUI

@MainActor
@Observable
class StandaloneFavoritesViewModel {

    // MARK: - Published Vars

    public var state: LoadingState<[AnyEquatableMedoContent]> = .loading

    public var contentSortOption: Int

    public var toast: Binding<Toast?>
    public var floatingOptions: Binding<FloatingContentOptions?>

    private let contentRepository: ContentRepositoryProtocol

    // MARK: - Initializer

    init(
        contentSortOption: Int,
        toast: Binding<Toast?>,
        floatingOptions: Binding<FloatingContentOptions?>,
        contentRepository: ContentRepositoryProtocol
    ) {
        self.contentSortOption = contentSortOption
        self.toast = toast
        self.floatingOptions = floatingOptions
        self.contentRepository = contentRepository
    }
}

// MARK: - User Actions

extension StandaloneFavoritesViewModel {

    public func onViewDidAppear() {
        print("StandaloneFavoritesView - ON APPEAR")

        loadContent()
    }

    public func onContentSortOptionChanged() {
        loadContent()
    }

    public func onExplicitContentSettingChanged() {
        loadContent()
    }
}

// MARK: - Internal Functions

extension StandaloneFavoritesViewModel {

    private func loadContent() {
        state = .loading

        do {
            let allowSensitive = UserSettings().getShowExplicitContent()
            let sort = SoundSortOption(rawValue: contentSortOption) ?? .dateAddedDescending
            state = .loaded(try contentRepository.favorites(allowSensitive, sort))
        } catch {
            state = .error(error.localizedDescription)
            debugPrint(error)
        }
    }
}
