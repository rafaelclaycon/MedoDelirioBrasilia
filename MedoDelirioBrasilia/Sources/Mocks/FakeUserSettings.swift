//
//  FakeUserSettings.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 30/10/24.
//

import Foundation

final class FakeUserSettings: UserSettingsProtocol {

    var showExplicitContent = false
    var hasJoinedFolderResearch = false

    func getShowExplicitContent() -> Bool {
        return showExplicitContent
    }

    func getHasJoinedFolderResearch() -> Bool {
        return hasJoinedFolderResearch
    }

    func authorSortOption(_ newValue: Int) {
        //
    }
}
