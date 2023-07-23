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

    private var showSyncProgressHistory: [Bool]!
    private var updateSoundListHistory: [Bool]!
    private var currentAmountHistory: [Double]!
    private var totalAmountHistory: [Double]!

    override func setUp() {
        syncService = SyncServiceStub()
        databaseStub = LocalDatabaseStub()

        showSyncProgressHistory = []
        updateSoundListHistory = []
        currentAmountHistory = []
        totalAmountHistory = []
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

    func test_sync_whenNoUpdates_shouldLoadSoundList() async throws {
        databaseStub.unsuccessfulUpdatesToReturn = []
        syncService.updates = []
        sut = MainViewViewModel(lastUpdateDate: firstRunLastUpdateDate,
                                service: syncService,
                                database: databaseStub)

        let pubA = sut.$showSyncProgressView
            .sink { self.showSyncProgressHistory.append($0) }

        let pubB = sut.$updateSoundList
            .sink { self.updateSoundListHistory.append($0) }

        let pubC = sut.$currentAmount
            .sink { self.currentAmountHistory.append($0) }

        let pubD = sut.$totalAmount
            .sink { self.totalAmountHistory.append($0) }

        await sut.sync()

        XCTAssertEqual(showSyncProgressHistory, [false, true, false])
        XCTAssertEqual(updateSoundListHistory, [false, true])
        XCTAssertEqual(currentAmountHistory, [0.0])
        XCTAssertEqual(totalAmountHistory, [1.0])
        XCTAssertEqual(syncService.timesProcessWasCalled, 0)
    }

    func test_sync_whenOneSoundCreatedUpdate_shouldDownloadSoundAndLoadSoundList() async throws {
        databaseStub.unsuccessfulUpdatesToReturn = []
        syncService.updates = [
            UpdateEvent(contentId: "123", mediaType: .sound, eventType: .created)
        ]
        sut = MainViewViewModel(lastUpdateDate: firstRunLastUpdateDate,
                                service: syncService,
                                database: databaseStub)

        let pubA = sut.$showSyncProgressView
            .sink { self.showSyncProgressHistory.append($0) }

        let pubB = sut.$updateSoundList
            .sink { self.updateSoundListHistory.append($0) }

        let pubC = sut.$currentAmount
            .sink { self.currentAmountHistory.append($0) }

        let pubD = sut.$totalAmount
            .sink { self.totalAmountHistory.append($0) }

        await sut.sync()

        XCTAssertEqual(showSyncProgressHistory, [false, true, false])
        XCTAssertEqual(updateSoundListHistory, [false, true])
        XCTAssertEqual(currentAmountHistory, [0.0, 1.0])
        XCTAssertEqual(totalAmountHistory, [1.0, 1.0])
        XCTAssertEqual(syncService.timesProcessWasCalled, 1)
    }

    func test_sync_whenTwoSoundCreatedUpdates_shouldDownloadSoundsAndLoadSoundList() async throws {
        databaseStub.unsuccessfulUpdatesToReturn = []
        syncService.updates = [
            UpdateEvent(contentId: "123", mediaType: .sound, eventType: .created),
            UpdateEvent(contentId: "456", mediaType: .sound, eventType: .created)
        ]
        sut = MainViewViewModel(lastUpdateDate: firstRunLastUpdateDate,
                                service: syncService,
                                database: databaseStub)

        let pubA = sut.$showSyncProgressView
            .sink { self.showSyncProgressHistory.append($0) }

        let pubB = sut.$updateSoundList
            .sink { self.updateSoundListHistory.append($0) }

        let pubC = sut.$currentAmount
            .sink { self.currentAmountHistory.append($0) }

        let pubD = sut.$totalAmount
            .sink { self.totalAmountHistory.append($0) }

        await sut.sync()

        XCTAssertEqual(showSyncProgressHistory, [false, true, false])
        XCTAssertEqual(updateSoundListHistory, [false, true])
        XCTAssertEqual(currentAmountHistory, [0.0, 1.0, 2.0])
        XCTAssertEqual(totalAmountHistory, [1.0, 2.0])
        XCTAssertEqual(syncService.timesProcessWasCalled, 2)
    }

    // Internet becomes unavailable in the middle of sync
    func test_sync_whenManyUpdatesAndInternetBecomesUnavailableInTheMiddleOfSync_shouldSyncWhatItCanAndLoadSoundList() async throws {
        databaseStub.unsuccessfulUpdatesToReturn = []
        syncService.updates = [
            UpdateEvent(contentId: "123", mediaType: .sound, eventType: .created),
            UpdateEvent(contentId: "456", mediaType: .sound, eventType: .created),
            UpdateEvent(contentId: "789", mediaType: .sound, eventType: .fileUpdated),
            UpdateEvent(contentId: "101112", mediaType: .sound, eventType: .metadataUpdated),
            UpdateEvent(contentId: "131415", mediaType: .sound, eventType: .metadataUpdated)
        ]
        syncService.loseConectivityAfterUpdate = 3
        sut = MainViewViewModel(lastUpdateDate: firstRunLastUpdateDate,
                                service: syncService,
                                database: databaseStub)

        let pubA = sut.$showSyncProgressView
            .sink { self.showSyncProgressHistory.append($0) }

        let pubB = sut.$updateSoundList
            .sink { self.updateSoundListHistory.append($0) }

        let pubC = sut.$currentAmount
            .sink { self.currentAmountHistory.append($0) }

        let pubD = sut.$totalAmount
            .sink { self.totalAmountHistory.append($0) }

        await sut.sync()

        XCTAssertEqual(showSyncProgressHistory, [false, true, false])
        XCTAssertEqual(updateSoundListHistory, [false, true])
        XCTAssertEqual(currentAmountHistory, [0.0, 1.0, 2.0, 3.0])
        XCTAssertEqual(totalAmountHistory, [1.0, 5.0])
        XCTAssertEqual(syncService.timesProcessWasCalled, 3)
    }
}
