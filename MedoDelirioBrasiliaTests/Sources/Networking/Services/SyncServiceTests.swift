//
//  SyncServiceTests.swift
//  MedoDelirioBrasiliaTests
//
//  Created by Rafael Schmitt on 03/05/23.
//

import XCTest
@testable import MedoDelirio

final class SyncServiceTests: XCTestCase {

    private var sut: SyncService!

    private var apiClient: FakeAPIClient!
    private var localDatabase: FakeLocalDatabase!

    override func setUp() {
        apiClient = FakeAPIClient()
        localDatabase = FakeLocalDatabase()
        sut = SyncService(apiClient: apiClient, localDatabase: localDatabase)
    }

    override func tearDown() {
        sut = nil
        localDatabase = nil
        apiClient = nil
        super.tearDown()
    }

    func testGetUpdates_whenNoInternetConnection_shouldReturnSyncError() async throws {
        // Given
        apiClient.serverShouldBeUnavailable = true

        // When
        let updates = try await sut.getUpdates(from: "all")

        // Then
        XCTAssertTrue(updates.isEmpty)
    }

    func testGetUpdates_whenNoChanges_shouldReturnNothingToUpdate() async throws {
        apiClient.fetchUpdateEventsResult = .nothingToUpdate
        
        let updates = try await sut.getUpdates(from: "all")

        XCTAssertTrue(updates.isEmpty)
    }

//    func testGetUpdates_syncWithServer_serverError() async throws {
//        apiClient.fetchUpdateEventsResult = .updateError
//        
//        let updates = try await sut.getUpdates(from: "all")
//
//        XCTAssertEqual(updates)
//    }
}
