//
//  MainViewViewModelTests.swift
//  MedoDelirioBrasiliaTests
//
//  Created by Rafael Schmitt on 08/07/23.
//

@testable import MedoDelirio
import XCTest

@MainActor
final class MainViewViewModelTests: XCTestCase {

    private var sut: MainViewViewModel!

    private var syncService: SyncServiceStub!
    private var databaseStub: LocalDatabaseStub!

    private let firstRunLastUpdateDate = "all"

    override func setUp() {
        syncService = SyncServiceStub()
        databaseStub = LocalDatabaseStub()
    }

    override func tearDown() {
        sut = nil
        syncService = nil
        databaseStub = nil
    }

    func test_sync_whenNoInternetConnection_shouldDisplayYoureOffline() async throws {
        syncService.hasConnectivityResult = false
        sut = MainViewViewModel(lastUpdateDate: firstRunLastUpdateDate,
                                service: syncService,
                                database: databaseStub)

        await sut.sync()

        XCTAssertFalse(sut.showSyncProgressView)
        XCTAssertTrue(sut.showYoureOfflineWarning)
    }

    @MainActor
    func test_sync_whenNoUpdates_shouldLoadSoundList() async throws {
        databaseStub.unsuccessfulUpdatesToReturn = []
        syncService.predefinedUpdates = []
        sut = MainViewViewModel(lastUpdateDate: firstRunLastUpdateDate,
                                service: syncService,
                                database: databaseStub)

        let showSyncProgressViewPublisher = sut.$showSyncProgressView
            .collect(2)
            .first()

        await sut.sync()

        let showArrays = try awaitPublisher(showSyncProgressViewPublisher)
        XCTAssertEqual(showArrays.count, 2)
        print(showArrays)
        XCTAssertTrue(sut.updateSoundList)
    }

    func test_sync_whenOneSoundCreatedUpdate_shouldDownloadSoundAndLoadSoundList() async throws {
        databaseStub.unsuccessfulUpdatesToReturn = []
        syncService.predefinedUpdates = [UpdateEvent(contentId: "123", mediaType: .sound, eventType: .created)]
        sut = MainViewViewModel(lastUpdateDate: firstRunLastUpdateDate,
                                service: syncService,
                                database: databaseStub)

        let showSyncProgressViewPublisher = sut.$showSyncProgressView
            .collect(2)
            .first()

        await sut.sync()

        let showArrays = try awaitPublisher(showSyncProgressViewPublisher)
        XCTAssertEqual(showArrays.count, 2)
        print(showArrays)
        XCTAssertTrue(sut.updateSoundList)
    }

    // Internet becomes unavailable in the middle of sync
}
