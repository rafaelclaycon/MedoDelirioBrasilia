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

    var data: [AnyEquatableMedoContent]?

    var contentSortOption: Int
    var dataLoadingDidFail: Bool = false

    var toast: Toast?

    // MARK: - Initializer

    init(
        contentSortOption: Int
    ) {
        self.contentSortOption = contentSortOption
    }
}

// MARK: - User Actions

extension StandaloneFavoritesViewModel {

    public func onViewDidAppear() {
        print("StandaloneFavoritesView - ON APPEAR")

        loadContent()
    }

    public func onSoundSortOptionChanged() {
        sortSounds(by: contentSortOption)
    }

    public func onExplicitContentSettingChanged() {
        loadContent()
    }
}

// MARK: - Internal Functions

extension StandaloneFavoritesViewModel {

    private func loadContent() {
        do {
            let sounds: [AnyEquatableMedoContent] = try LocalDatabase.shared.sounds(
                allowSensitive: UserSettings().getShowExplicitContent()
            ).map { AnyEquatableMedoContent($0) }
            let songs: [AnyEquatableMedoContent] = try LocalDatabase.shared.songs(
                allowSensitive: UserSettings().getShowExplicitContent()
            ).map { AnyEquatableMedoContent($0) }

            data = sounds + songs

            guard sounds.count > 0 else { return }
            let sortOption: SoundSortOption = SoundSortOption(rawValue: contentSortOption) ?? .dateAddedDescending
            sortData(by: sortOption)
        } catch {
            print("Erro carregando sons: \(error.localizedDescription)")
            dataLoadingDidFail = true
        }
    }

    private func sortSounds(by rawSortOption: Int) {
        let sortOption = SoundSortOption(rawValue: rawSortOption) ?? .dateAddedDescending
        sortData(by: sortOption)
        UserSettings().saveMainSoundListSoundSortOption(rawSortOption)
    }
}

// MARK: - Sorting

extension StandaloneFavoritesViewModel {

    private func sortData(by sortOption: SoundSortOption) {
        switch sortOption {
        case .titleAscending:
            sortAllSoundsByTitleAscending()
        case .authorNameAscending:
            sortAllSoundsByAuthorNameAscending()
        case .dateAddedDescending:
            sortAllSoundsByDateAddedDescending()
        case .shortestFirst:
            sortAllSoundsByDurationAscending()
        case .longestFirst:
            sortAllSoundsByDurationDescending()
        case .longestTitleFirst:
            sortAllSoundsByTitleLengthDescending()
        case .shortestTitleFirst:
            sortAllSoundsByTitleLengthAscending()
        }
    }

    private func sortAllSoundsByTitleAscending() {
        DispatchQueue.main.async {
            self.data?.sort(by: { $0.title.withoutDiacritics() < $1.title.withoutDiacritics() })
        }
    }

    private func sortAllSoundsByAuthorNameAscending() {
        DispatchQueue.main.async {
            self.data?.sort(by: { $0.subtitle.withoutDiacritics() < $1.subtitle.withoutDiacritics() })
        }
    }

    private func sortAllSoundsByDateAddedDescending() {
        DispatchQueue.main.async {
            self.data?.sort(by: { $0.dateAdded ?? Date() > $1.dateAdded ?? Date() })
        }
    }

    private func sortAllSoundsByDurationAscending() {
        DispatchQueue.main.async {
            self.data?.sort(by: { $0.duration < $1.duration })
        }
    }

    private func sortAllSoundsByDurationDescending() {
        DispatchQueue.main.async {
            self.data?.sort(by: { $0.duration > $1.duration })
        }
    }

    private func sortAllSoundsByTitleLengthAscending() {
        DispatchQueue.main.async {
            self.data?.sort(by: { $0.title.count < $1.title.count })
        }
    }

    private func sortAllSoundsByTitleLengthDescending() {
        DispatchQueue.main.async {
            self.data?.sort(by: { $0.title.count > $1.title.count })
        }
    }
}
