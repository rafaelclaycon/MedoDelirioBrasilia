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

    private let firstRunLastUpdateDate = "all"

    override func setUp() {
        syncService = SyncServiceStub()
    }

    override func tearDown() {
        sut = nil
    }

    func test_sync_whenNoInternetConnection_shouldDisplayYoureOffline() async throws {
        syncService.hasConnectivityResult = false
        sut = MainViewViewModel(lastUpdateDate: firstRunLastUpdateDate, service: syncService)

        //let expectation = XCTestExpectation()

        await sut.sync()

        //expectation.fulfill()

        XCTAssertFalse(sut.showSyncProgressView)
        XCTAssertTrue(sut.showYoureOfflineWarning)
    }

    func test_sync_whenNoUpdates_shouldLoadSoundList() async throws {
        sut = MainViewViewModel(lastUpdateDate: firstRunLastUpdateDate, service: syncService)

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
