//
//  ContentUpdateServiceTests.swift
//  MedoDelirioBrasiliaTests
//
//  Created by Rafael Schmitt on 03/05/23.
//

import Testing
@testable import MedoDelirio

@MainActor
struct ContentUpdateServiceTests {

    private var service: ContentUpdateService!

    private var apiClient: FakeAPIClient!
    private var localDatabase: FakeLocalDatabase!
    private var appMemory: FakeAppPersistentMemory!
    private var logger: FakeLoggerService!
    private var delegate: FakeContentUpdateServiceDelegate!

    init() {
        self.apiClient = FakeAPIClient()
        self.localDatabase = FakeLocalDatabase()
        self.appMemory = FakeAppPersistentMemory()
        self.logger = FakeLoggerService()
        self.delegate = FakeContentUpdateServiceDelegate()

        self.service = ContentUpdateService(
            apiClient: apiClient,
            database: localDatabase,
            appMemory: appMemory,
            logger: logger
        )
        self.service.delegate = delegate
    }

    @Test
    func testUpdate_whenNotAllowedYet_shouldReturnPendingStatus() async throws {
        await service.update()

        #expect(delegate.statusUpdates.count == 1)
        #expect(delegate.statusUpdates.first?.0 == ContentUpdateStatus.pendingFirstUpdate)
    }

    
}
