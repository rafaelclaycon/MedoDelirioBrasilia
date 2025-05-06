//
//  MockUserSettings.swift
//  MedoDelirioBrasiliaTests
//
//  Created by Rafael Schmitt on 30/10/24.
//

import Foundation
@testable import MedoDelirio

final class MockUserSettings: UserSettingsProtocol {

    var hasJoinedFolderResearch = false

    func getHasJoinedFolderResearch() -> Bool {
        return hasJoinedFolderResearch
    }

    func authorSortOption(_ newValue: Int) {
        //
    }
}
