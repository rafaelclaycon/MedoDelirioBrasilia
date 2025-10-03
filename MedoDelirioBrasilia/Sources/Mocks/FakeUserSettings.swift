//
//  FakeUserSettings.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 30/10/24.
//

import Foundation

final class FakeUserSettings: UserSettingsProtocol {

    var hasJoinedFolderResearch = false

    func getHasJoinedFolderResearch() -> Bool {
        return hasJoinedFolderResearch
    }

    func authorSortOption(_ newValue: Int) {
        //
    }
}
