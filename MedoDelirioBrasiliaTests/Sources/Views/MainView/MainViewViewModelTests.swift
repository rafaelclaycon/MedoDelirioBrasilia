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
    private var loggerStub: LoggerStub!

    private let firstRunLastUpdateDate = "all"

    private var showSyncProgressHistory: [Bool]!
    private var updateSoundListHistory: [Bool]!
    private var currentAmountHistory: [Double]!
    private var totalAmountHistory: [Double]!

    override func setUp() {
        syncService = SyncServiceStub()
        databaseStub = LocalDatabaseStub()
        loggerStub = LoggerStub()

        showSyncProgressHistory = []
        updateSoundListHistory = []
        currentAmountHistory = []
        totalAmountHistory = []
    }

    override func tearDown() {
        sut = nil
        syncService = nil
        databaseStub = nil
        loggerStub = nil
    }

//    func test_sync_whenNoInternetConnection_shouldDisplayYoureOffline() async throws {
//        syncService.hasConnectivityResult = false
//        sut = MainViewViewModel(lastUpdateDate: firstRunLastUpdateDate,
//                                service: syncService,
//                                database: databaseStub,
//                                logger: loggerStub)
//
//        await sut.sync()
//
//        XCTAssertFalse(sut.showSyncProgressView)
//        //XCTAssertTrue(sut.showYoureOfflineWarning)
//    }

    func test_sync_whenNoUpdates_shouldLoadSoundList() async throws {
        databaseStub.unsuccessfulUpdatesToReturn = []
        syncService.updates = []
        sut = MainViewViewModel(lastUpdateDate: firstRunLastUpdateDate,
                                service: syncService,
                                database: databaseStub,
                                logger: loggerStub)

//        let pubA = sut.$showSyncProgressView
//            .sink { self.showSyncProgressHistory.append($0) }

        let pubB = sut.$updateSoundList
            .sink { self.updateSoundListHistory.append($0) }

//        let pubC = sut.$currentAmount
//            .sink { self.currentAmountHistory.append($0) }
//
//        let pubD = sut.$totalAmount
//            .sink { self.totalAmountHistory.append($0) }

        await sut.sync()

        //XCTAssertEqual(showSyncProgressHistory, [false, true, false])
        XCTAssertEqual(updateSoundListHistory, [false, true])
        //XCTAssertEqual(currentAmountHistory, [0.0])
        //XCTAssertEqual(totalAmountHistory, [1.0])
        XCTAssertEqual(syncService.timesProcessWasCalled, 0)
    }

    func test_sync_whenOneSoundCreatedUpdate_shouldDownloadSoundAndLoadSoundList() async throws {
        databaseStub.unsuccessfulUpdatesToReturn = []
        syncService.updates = [
            UpdateEvent(contentId: "123", mediaType: .sound, eventType: .created)
        ]
        sut = MainViewViewModel(lastUpdateDate: firstRunLastUpdateDate,
                                service: syncService,
                                database: databaseStub,
                                logger: loggerStub)

//        let pubA = sut.$showSyncProgressView
//            .sink { self.showSyncProgressHistory.append($0) }

        let pubB = sut.$updateSoundList
            .sink { self.updateSoundListHistory.append($0) }

//        let pubC = sut.$currentAmount
//            .sink { self.currentAmountHistory.append($0) }
//
//        let pubD = sut.$totalAmount
//            .sink { self.totalAmountHistory.append($0) }

        await sut.sync()

        //XCTAssertEqual(showSyncProgressHistory, [false, true, false])
        XCTAssertEqual(updateSoundListHistory, [false, true])
        //XCTAssertEqual(currentAmountHistory, [0.0, 1.0])
        //XCTAssertEqual(totalAmountHistory, [1.0, 1.0])
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
                                database: databaseStub,
                                logger: loggerStub)

//        let pubA = sut.$showSyncProgressView
//            .sink { self.showSyncProgressHistory.append($0) }

        let pubB = sut.$updateSoundList
            .sink { self.updateSoundListHistory.append($0) }

//        let pubC = sut.$currentAmount
//            .sink { self.currentAmountHistory.append($0) }
//
//        let pubD = sut.$totalAmount
//            .sink { self.totalAmountHistory.append($0) }

        await sut.sync()

        //XCTAssertEqual(showSyncProgressHistory, [false, true, false])
        XCTAssertEqual(updateSoundListHistory, [false, true])
        //XCTAssertEqual(currentAmountHistory, [0.0, 1.0, 2.0])
        //XCTAssertEqual(totalAmountHistory, [1.0, 2.0])
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
                                database: databaseStub,
                                logger: loggerStub)

//        let pubA = sut.$showSyncProgressView
//            .sink { self.showSyncProgressHistory.append($0) }

        let pubB = sut.$updateSoundList
            .sink { self.updateSoundListHistory.append($0) }

//        let pubC = sut.$currentAmount
//            .sink { self.currentAmountHistory.append($0) }
//
//        let pubD = sut.$totalAmount
//            .sink { self.totalAmountHistory.append($0) }

        await sut.sync()

        //XCTAssertEqual(showSyncProgressHistory, [false, true, false])
        XCTAssertEqual(updateSoundListHistory, [false, true])
        //XCTAssertEqual(currentAmountHistory, [0.0, 1.0, 2.0, 3.0])
        //XCTAssertEqual(totalAmountHistory, [1.0, 5.0])
        XCTAssertEqual(syncService.timesProcessWasCalled, 3)
    }

    func test_sync_whenServerIsUnavailable_shouldLoadSoundList() async throws {
        databaseStub.unsuccessfulUpdatesToReturn = []
        syncService.updates = [
            UpdateEvent(contentId: "123", mediaType: .sound, eventType: .created),
            UpdateEvent(contentId: "456", mediaType: .sound, eventType: .created),
            UpdateEvent(contentId: "789", mediaType: .sound, eventType: .fileUpdated),
            UpdateEvent(contentId: "101112", mediaType: .sound, eventType: .metadataUpdated),
            UpdateEvent(contentId: "131415", mediaType: .sound, eventType: .metadataUpdated)
        ]
        syncService.errorToThrowOnUpdate = .errorFetchingUpdateEvents("Não foi possível conectar ao servidor.")
        sut = MainViewViewModel(lastUpdateDate: firstRunLastUpdateDate,
                                service: syncService,
                                database: databaseStub,
                                logger: loggerStub)

//        let pubA = sut.$showSyncProgressView
//            .sink { self.showSyncProgressHistory.append($0) }

        let pubB = sut.$updateSoundList
            .sink { self.updateSoundListHistory.append($0) }

//        let pubC = sut.$currentAmount
//            .sink { self.currentAmountHistory.append($0) }
//
//        let pubD = sut.$totalAmount
//            .sink { self.totalAmountHistory.append($0) }

        await sut.sync()

        //XCTAssertEqual(showSyncProgressHistory, [false, true, false])
        XCTAssertEqual(updateSoundListHistory, [false, true])
        //XCTAssertEqual(currentAmountHistory, [0.0])
        //XCTAssertEqual(totalAmountHistory, [1.0])
        XCTAssertEqual(syncService.timesProcessWasCalled, 0)
        XCTAssertEqual(loggerStub.errorHistory, ["Não foi possível conectar ao servidor.": ""])
    }

    func test_sync_whenDatabaseErrorLikeUniqueConstraintFailed_shouldLogErrorAndLoadSoundList() async throws {
        let updateEventUUIDString = "5B3CC177-E5CD-45EE-A2BF-8FFB1AC01A9D"

        databaseStub.unsuccessfulUpdatesToReturn = []
        syncService.updates = [
            UpdateEvent(id: UUID(uuidString: updateEventUUIDString)!, contentId: "123", mediaType: .sound, eventType: .created),
            UpdateEvent(contentId: "456", mediaType: .sound, eventType: .created),
            UpdateEvent(contentId: "789", mediaType: .sound, eventType: .fileUpdated),
            UpdateEvent(contentId: "101112", mediaType: .sound, eventType: .metadataUpdated),
            UpdateEvent(contentId: "131415", mediaType: .sound, eventType: .metadataUpdated)
        ]
        databaseStub.errorToThrowOnInsertUpdateEvent = .databaseError(message: "UNIQUE constraint failed: updateEvent.id (code: 19)")
        sut = MainViewViewModel(lastUpdateDate: firstRunLastUpdateDate,
                                service: syncService,
                                database: databaseStub,
                                logger: loggerStub)

//        let pubA = sut.$showSyncProgressView
//            .sink { self.showSyncProgressHistory.append($0) }

        let pubB = sut.$updateSoundList
            .sink { self.updateSoundListHistory.append($0) }

//        let pubC = sut.$currentAmount
//            .sink { self.currentAmountHistory.append($0) }
//
//        let pubD = sut.$totalAmount
//            .sink { self.totalAmountHistory.append($0) }

        await sut.sync()

        //XCTAssertEqual(showSyncProgressHistory, [false, true, false])
        XCTAssertEqual(updateSoundListHistory, [false, true])
        //XCTAssertEqual(currentAmountHistory, [0.0])
        //XCTAssertEqual(totalAmountHistory, [1.0])
        XCTAssertEqual(syncService.timesProcessWasCalled, 0)
        XCTAssertEqual(loggerStub.errorHistory, ["Erro ao tentar inserir UpdateEvent no banco de dados.": updateEventUUIDString])
    }

    func test_sync_whenHasSomeAlreadyProcessedUpdates_shouldContinueFromLastUpdateDateAndLoadSoundList() async throws {
        databaseStub.unsuccessfulUpdatesToReturn = []
        syncService.updates = [
            UpdateEvent(contentId: "123", dateTime: "2023-07-17T19:58:30Z", mediaType: .sound, eventType: .created),
            UpdateEvent(contentId: "456", dateTime: "2023-07-19T19:58:30Z", mediaType: .sound, eventType: .created),
            UpdateEvent(contentId: "789", dateTime: "2023-07-19T19:58:30Z", mediaType: .sound, eventType: .fileUpdated),
            UpdateEvent(contentId: "101112", dateTime: "2023-07-19T19:58:30Z", mediaType: .sound, eventType: .metadataUpdated),
            UpdateEvent(contentId: "131415", dateTime: "2023-07-21T19:58:30Z", mediaType: .sound, eventType: .metadataUpdated),
            // "2023-07-29T19:58:30Z"
            UpdateEvent(contentId: "3456", dateTime: "2023-07-30T08:01:47Z", mediaType: .sound, eventType: .created),
            UpdateEvent(contentId: "2355", dateTime: "2023-07-30T08:02:47Z", mediaType: .sound, eventType: .created),
            UpdateEvent(contentId: "119090", dateTime: "2023-07-30T08:03:47Z", mediaType: .song, eventType: .fileUpdated),
            UpdateEvent(contentId: "101112", dateTime: "2023-07-31T12:05:47Z", mediaType: .author, eventType: .metadataUpdated),
            UpdateEvent(contentId: "131415", dateTime: "2023-08-01T15:10:47Z", mediaType: .sound, eventType: .metadataUpdated)

        ]
        sut = MainViewViewModel(lastUpdateDate: "2023-07-29T19:58:30Z",
                                service: syncService,
                                database: databaseStub,
                                logger: loggerStub)

//        let pubA = sut.$showSyncProgressView
//            .sink { self.showSyncProgressHistory.append($0) }

        let pubB = sut.$updateSoundList
            .sink { self.updateSoundListHistory.append($0) }

//        let pubC = sut.$currentAmount
//            .sink { self.currentAmountHistory.append($0) }
//
//        let pubD = sut.$totalAmount
//            .sink { self.totalAmountHistory.append($0) }

        await sut.sync()

        //XCTAssertEqual(showSyncProgressHistory, [false, true, false])
        XCTAssertEqual(updateSoundListHistory, [false, true])
        //XCTAssertEqual(currentAmountHistory, [0.0, 1.0, 2.0, 3.0, 4.0, 5.0])
        //XCTAssertEqual(totalAmountHistory, [1.0, 5.0])
        XCTAssertEqual(syncService.timesProcessWasCalled, 5)
        XCTAssertNotNil(UserDefaults.standard.string(forKey: "lastUpdateDate"))
    }
}
