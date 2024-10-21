//
//  SyncManagerTests.swift
//  MedoDelirioBrasiliaTests
//
//  Created by Rafael Schmitt on 08/03/24.
//

import XCTest
@testable import MedoDelirio

final class SyncManagerTests: XCTestCase {

    private var sut: SyncManager!

    private var syncService: SyncServiceStub!
    private var localDatabase: LocalDatabaseStub!
    private var logger: LoggerStub!

    private let mockUpdates: [UpdateEvent] = [
        .init(id: UUID(uuidString: "6AE46488-4872-4C71-84D7-E38A69F123DD")!, contentId: "1", mediaType: .sound, eventType: .created),
        .init(id: UUID(uuidString: "EB73727F-E228-4025-9109-886A9C33CAC5")!, contentId: "1", mediaType: .sound, eventType: .created),
        .init(id: UUID(uuidString: "DC15BD2A-88BE-4C4D-9AE5-790856FAC919")!, contentId: "1", mediaType: .sound, eventType: .created),
        .init(id: UUID(uuidString: "22356F60-4F21-4847-821A-B4D228E3B161")!, contentId: "1", mediaType: .sound, eventType: .created),
        .init(id: UUID(uuidString: "58604F80-8840-4858-87DD-65EF4D016C37")!, contentId: "1", mediaType: .sound, eventType: .created)
    ]

    override func setUpWithError() throws {
        try super.setUpWithError()
        syncService = SyncServiceStub()
        localDatabase = LocalDatabaseStub()
        logger = LoggerStub()
    }

    override func tearDownWithError() throws {
        syncService = nil
        localDatabase = nil
        logger = nil
        try super.tearDownWithError()
    }
}

// MARK: - User Flows

extension SyncManagerTests {

    func testSync_whenNoInternetConnection_shouldReturnSyncError() async throws {
        syncService.errorToThrowOnUpdate = .errorFetchingUpdateEvents("")

        sut = SyncManager(service: syncService, database: localDatabase, logger: logger)

        await sut.sync()

        XCTAssertEqual(localDatabase.numberOfTimesInsertUpdateEventWasCalled, 0)
        XCTAssertEqual(logger.errorHistory.count, 1)
        XCTAssertEqual(logger.successHistory.count, 0)
    }

    func testSync_whenNoChanges_shouldReturnNothingToUpdate() async throws {
        syncService.updates = []

        sut = SyncManager(service: syncService, database: localDatabase, logger: logger)

        await sut.sync()

        XCTAssertEqual(localDatabase.numberOfTimesInsertUpdateEventWasCalled, 0)
        XCTAssertEqual(logger.errorHistory.count, 0)
        XCTAssertEqual(logger.successHistory.count, 1)
    }

    func testSync_whenSomeUpdates_shouldSuccessfullyExecuteExactNumberOfUpdates() async throws {
        syncService.updates = mockUpdates

        sut = SyncManager(service: syncService, database: localDatabase, logger: logger)

        await sut.sync()

        XCTAssertEqual(localDatabase.numberOfTimesInsertUpdateEventWasCalled, 5)
        XCTAssertEqual(logger.errorHistory.count, 0)
        XCTAssertEqual(logger.successHistory.count, 0) // Why is this zero?
    }

    func testSync_whenAlreadyHasSomeSuccessfulUpdatesAndLastUpdateDateIsAllForSomeReason_shouldSaveOnlyNewUpdates() async throws {
        syncService.updates = mockUpdates

        localDatabase.preexistingUpdates = [
            .init(id: UUID(uuidString: "6AE46488-4872-4C71-84D7-E38A69F123DD")!, contentId: "1", mediaType: .sound, eventType: .created),
            .init(id: UUID(uuidString: "EB73727F-E228-4025-9109-886A9C33CAC5")!, contentId: "1", mediaType: .sound, eventType: .created),
            .init(id: UUID(uuidString: "DC15BD2A-88BE-4C4D-9AE5-790856FAC919")!, contentId: "1", mediaType: .sound, eventType: .created)
        ]

        sut = SyncManager(service: syncService, database: localDatabase, logger: logger)

        await sut.sync()

        XCTAssertEqual(localDatabase.numberOfTimesInsertUpdateEventWasCalled, 2)
        XCTAssertEqual(logger.errorHistory.count, 0)
        XCTAssertEqual(logger.successHistory.count, 0) // Maybe this should be 1?
    }
}
