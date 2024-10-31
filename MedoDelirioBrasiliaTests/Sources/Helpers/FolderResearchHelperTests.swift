//
//  FolderResearchHelperTests.swift
//  MedoDelirioBrasiliaTests
//
//  Created by Rafael Schmitt on 30/10/24.
//

import XCTest
@testable import MedoDelirio

final class FolderResearchHelperTests: XCTestCase {

    private var sut: FolderResearchProvider!

    private var userSettings: MockUserSettings!
    private var appMemory: MockAppPersistentMemory!
    private var localDatabase: MockLocalDatabase!

    override func setUpWithError() throws {
        userSettings = MockUserSettings()
        appMemory = MockAppPersistentMemory()
        localDatabase = MockLocalDatabase()
        sut = FolderResearchProvider(
            userSettings: userSettings,
            appMemory: appMemory,
            localDatabase: localDatabase
        )
    }

    override func tearDownWithError() throws {
        sut = nil
        localDatabase = nil
        appMemory = nil
        userSettings = nil
    }

    func testHash_whenKnownString_shouldReturnSameHash() throws {
        let hash = sut.hash("Medo e Delírio em Brasília")
        XCTAssertEqual(hash, "548bf3409b5bf16f4effd1a85d3bea0652b5bd3b0b6c33a435306525c4171f5d")
    }

    /// User has to be enrolled
    /// Changes need to have happened - we're assuming a first time send always upon enrollment
    /// Return only what's changed

    func testChanges_whenUserIsNotEnrolled_shouldReturnNil() async throws {
        userSettings.hasJoinedFolderResearch = false

        XCTAssertNil(sut.changes())
    }

    func testChanges_whenUserIsEnrolledButNoChanges_shouldReturnNil() async throws {
        userSettings.hasJoinedFolderResearch = true

        XCTAssertNil(sut.changes())
    }

    func testChanges_whenUserIsEnrolledAndThereAreChanges_shouldReturnOnlyWhatsChanged() async throws {
        XCTAssertNil(sut.changes())
    }
}
