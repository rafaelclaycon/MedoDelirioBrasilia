//
//  FolderResearchProviderTests.swift
//  MedoDelirioBrasiliaTests
//
//  Created by Rafael Schmitt on 30/10/24.
//

import XCTest
@testable import MedoDelirio

final class FolderResearchProviderTests: XCTestCase {

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
}

// MARK: - Hash

extension FolderResearchProviderTests {

    func testHash_whenKnownString_shouldReturnSameHash() throws {
        let hash = FolderResearchProvider.hash("Medo e Delírio em Brasília")
        XCTAssertEqual(hash, "548bf3409b5bf16f4effd1a85d3bea0652b5bd3b0b6c33a435306525c4171f5d")
    }
}

// MARK: - All

extension FolderResearchProviderTests {

    func testAll_whenFoldersAndContentExist_shouldReturnAll() async throws {
        localDatabase.folders = [
            .init(id: "abc", symbol: "🧪", name: "Memes", backgroundColor: "pastelBabyBlue"),
            .init(id: "def", symbol: "😡", name: "Xingar", backgroundColor: "pastelPurple")
        ]
        localDatabase.contentInsideFolder = [
            .init(userFolderId: "abc", contentId: "DDBB1BDE-9270-4FEA-904D-2D7DD85942B5")
        ]

        let info = try sut.all()

        XCTAssertEqual(info?.folders.count, 2)
        XCTAssertEqual(info?.content?.count, 1)
    }

    func testAll_whenNoFolders_shouldReturnNil() async throws {
        localDatabase.folders = []
        XCTAssertNil(try sut.all())
    }
}

// MARK: - Changes

extension FolderResearchProviderTests {

    /// User has to be enrolled
    /// Changes need to have happened - we're assuming a first time send always upon enrollment
    /// Return only what's changed

    func testChanges_whenUserIsNotEnrolled_shouldReturnNil() async throws {
        userSettings.hasJoinedFolderResearch = false
        XCTAssertNil(try sut.changes())
    }

    func testChanges_whenUserIsEnrolledButNoChanges_shouldReturnNil() async throws {
        userSettings.hasJoinedFolderResearch = true
        
        XCTAssertNil(try sut.changes())
    }

    func testChanges_whenUserIsEnrolledAndThereAreChanges_shouldReturnOnlyWhatsChanged() async throws {
        XCTAssertNil(try sut.changes())
    }
}
