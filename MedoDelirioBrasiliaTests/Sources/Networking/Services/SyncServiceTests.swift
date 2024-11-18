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

    private var networkRabbit: NetworkRabbitStub!
    private var localDatabase: FakeLocalDatabase!

    override func setUp() {
        networkRabbit = NetworkRabbitStub()
        localDatabase = FakeLocalDatabase()
        sut = SyncService(networkRabbit: networkRabbit, localDatabase: localDatabase)
    }

    override func tearDown() {
        sut = nil
        localDatabase = nil
        networkRabbit = nil
        super.tearDown()
    }

    func testGetUpdates_whenNoInternetConnection_shouldReturnSyncError() async throws {
        // Given
        networkRabbit.serverShouldBeUnavailable = true

        // When
        let updates = try await sut.getUpdates(from: "all")

        // Then
        XCTAssertTrue(updates.isEmpty)
    }

    func testGetUpdates_whenNoChanges_shouldReturnNothingToUpdate() async throws {
        networkRabbit.fetchUpdateEventsResult = .nothingToUpdate
        
        let updates = try await sut.getUpdates(from: "all")

        XCTAssertTrue(updates.isEmpty)
    }

//    func testGetUpdates_syncWithServer_serverError() async throws {
//        networkRabbit.fetchUpdateEventsResult = .updateError
//        
//        let updates = try await sut.getUpdates(from: "all")
//
//        XCTAssertEqual(updates)
//    }
}
