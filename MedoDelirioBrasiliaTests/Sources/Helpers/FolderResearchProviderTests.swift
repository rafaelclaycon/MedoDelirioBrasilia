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
    private var localDatabase: FakeLocalDatabase!
    private var repository: FakeFolderResearchRepository!

    override func setUpWithError() throws {
        userSettings = MockUserSettings()
        appMemory = MockAppPersistentMemory()
        localDatabase = FakeLocalDatabase()
        repository = FakeFolderResearchRepository()
        sut = FolderResearchProvider(
            userSettings: userSettings,
            appMemory: appMemory,
            localDatabase: localDatabase,
            repository: repository
        )
    }

    override func tearDownWithError() throws {
        sut = nil
        repository = nil
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
        var firstMock = UserFolder.mockA
        firstMock.changeHash = UserFolder.mockA.folderHash([mockContent1])
        localDatabase.folders = [firstMock, .mockB]
        localDatabase.contentInsideFolder = [
            .init(userFolderId: UserFolder.mockA.id, contentId: mockContent1)
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

// MARK: - Right After Update

extension FolderResearchProviderTests {

    func testChanges_whenUserIsEnrolledHasSentFirstTimeAndJustUpdatedToTheNewVersion_shouldReturnAll() async throws {
        var firstMock = UserFolder.mockA
        firstMock.changeHash = UserFolder.mockA.folderHash([mockContent1])
        var secondMock = UserFolder.mockB
        secondMock.changeHash = UserFolder.mockB.folderHash([])
        localDatabase.folders = [firstMock, secondMock]
        localDatabase.contentInsideFolder = [
            .init(userFolderId: UserFolder.mockA.id, contentId: mockContent1)
        ]
        appMemory.folderResearchHashValue = nil

        userSettings.hasJoinedFolderResearch = true
        appMemory.hasSentFolderResearchInfo = true

        let changes = try sut.changes()
        XCTAssertEqual(changes?.folders.count, 2)
        XCTAssertEqual(changes?.content?.count, 1)
    }

    /// If for some reason the first time run setting of hashes doesn't run, should still return all.
    func testChanges_whenUserIsEnrolledHasSentFirstTimeJustUpdatedAndHashesNotSetOnFolders_shouldReturnAll() async throws {
        localDatabase.folders = [.mockA, .mockB]
        localDatabase.contentInsideFolder = [
            .init(userFolderId: UserFolder.mockA.id, contentId: mockContent1)
        ]
        appMemory.folderResearchHashValue = nil

        userSettings.hasJoinedFolderResearch = true
        appMemory.hasSentFolderResearchInfo = true

        let changes = try sut.changes()
        XCTAssertEqual(changes?.folders.count, 2)
        XCTAssertEqual(changes?.content?.count, 1)
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

    func testChanges_whenUserIsEnrolledHasSentFirstTimeButNoChanges_shouldReturnNil() async throws {
        var firstMock = UserFolder.mockA
        firstMock.changeHash = UserFolder.mockA.folderHash([mockContent1])
        var secondMock = UserFolder.mockB
        secondMock.changeHash = UserFolder.mockB.folderHash([])
        localDatabase.folders = [firstMock, secondMock]
        localDatabase.contentInsideFolder = [
            .init(userFolderId: UserFolder.mockA.id, contentId: mockContent1)
        ]
        appMemory.folderResearchHashValue = [
            UserFolder.mockA.id: "af51a20cac90a933229931b74ba765de3c0e9cd7ec0fab62f2917403835fe02f",
            UserFolder.mockB.id: "38596ee9cd1ce031a339497eeaf326f28927ca1e5db10907d01e22d619a98a47"
        ]

        userSettings.hasJoinedFolderResearch = true
        appMemory.hasSentFolderResearchInfo = true

        XCTAssertNil(try sut.changes())
    }

    func testChanges_whenUserIsEnrolledAndAddedSoundsToOneFolder_shouldReturnOnlyThatFolderAndAllSounds() async throws {
        var firstMock = UserFolder.mockA
        firstMock.changeHash = UserFolder.mockA.folderHash([mockContent1, mockContent2, mockContent3])
        var secondMock = UserFolder.mockB
        secondMock.changeHash = UserFolder.mockB.folderHash([])
        localDatabase.folders = [firstMock, secondMock]
        localDatabase.contentInsideFolder = [
            .init(userFolderId: UserFolder.mockA.id, contentId: mockContent1),
            .init(userFolderId: UserFolder.mockA.id, contentId: mockContent2),
            .init(userFolderId: UserFolder.mockA.id, contentId: mockContent3)
        ]
        appMemory.folderResearchHashValue = [
            UserFolder.mockA.id: "af51a20cac90a933229931b74ba765de3c0e9cd7ec0fab62f2917403835fe02f", // Added new sounds
            UserFolder.mockB.id: "38596ee9cd1ce031a339497eeaf326f28927ca1e5db10907d01e22d619a98a47" // Did not change
        ]

        userSettings.hasJoinedFolderResearch = true
        appMemory.hasSentFolderResearchInfo = true

        let changes = try sut.changes()
        XCTAssertEqual(changes?.folders.count, 1)
        XCTAssertEqual(changes?.folders.first?.name, UserFolder.mockA.name)
        XCTAssertEqual(changes?.content?.count, 3)
    }

    func testChanges_whenUserIsEnrolledAndChangedOneFoldersName_shouldReturnOnlyThatFolderAndAllSounds() async throws {
        var firstMock = UserFolder.mockA
        firstMock.changeHash = firstMock.folderHash([mockContent1, mockContent2, mockContent3])
        var secondMock = UserFolder.mockB
        secondMock.name = "Só rindo!"
        secondMock.changeHash = secondMock.folderHash([mockContent3])
        localDatabase.folders = [firstMock, secondMock]
        localDatabase.contentInsideFolder = [
            .init(userFolderId: UserFolder.mockA.id, contentId: mockContent1),
            .init(userFolderId: UserFolder.mockA.id, contentId: mockContent2),
            .init(userFolderId: UserFolder.mockA.id, contentId: mockContent3),
            .init(userFolderId: UserFolder.mockB.id, contentId: mockContent3)
        ]
        appMemory.folderResearchHashValue = [
            UserFolder.mockA.id: "a44752bd841401e84f1ce68a8396238c1d95bdf777035a93773332caea8ac420", // No changes
            UserFolder.mockB.id: "38596ee9cd1ce031a339497eeaf326f28927ca1e5db10907d01e22d619a98a47" // Changed name
        ]

        userSettings.hasJoinedFolderResearch = true
        appMemory.hasSentFolderResearchInfo = true

        let changes = try sut.changes()
        XCTAssertEqual(changes?.folders.count, 1)
        XCTAssertEqual(changes?.folders.first?.name, "Só rindo!")
        XCTAssertEqual(changes?.content?.count, 1)
    }
}

extension FolderResearchProviderTests {

    private var mockContent1: String {
        "DDBB1BDE-9270-4FEA-904D-2D7DD85942B5"
    }

    private var mockContent2: String {
        "2DA3FCD0-3C95-4194-9DD0-923B82EC338A"
    }

    private var mockContent3: String {
        "3BA404C1-41B8-48E5-9994-11F70E096402"
    }
}
