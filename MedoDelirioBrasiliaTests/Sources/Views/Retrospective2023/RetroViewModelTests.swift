//
//  RetroViewModelTests.swift
//  MedoDelirioBrasiliaTests
//
//  Created by Rafael Schmitt on 16/10/23.
//

@testable import MedoDelirio
import XCTest

final class RetroViewModelTests: XCTestCase {

    private var sut: ClassicRetroView.ViewModel!

    private var localDatabase: FakeLocalDatabase!

    @MainActor
    override func setUpWithError() throws {
        try super.setUpWithError()
        localDatabase = .init()
        sut = .init(database: localDatabase)
    }

    override func tearDownWithError() throws {
        sut = nil
        localDatabase = nil
        try super.tearDownWithError()
    }

    private func date(from isoDate: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter.date(from: isoDate)!
    }

    @MainActor
    func testDayOfTheWeekFromDate() async throws {
        XCTAssertEqual(sut.dayOfTheWeek(from: date(from: "2023-10-16T23:36:27.074")), "segunda-feira")
    }

    @MainActor
    func testMostCommonDay_whenNoDates_thenNilReturned() async throws {
        let dates: [Date] = []
        XCTAssertNil(sut.mostCommonDay(from: dates))
    }

    @MainActor
    func testMostCommonDay_whenOnlySingleDaySaturday_thenSaturdayIsReturned() async throws {
        let dates: [Date] = [
            date(from: "2023-01-07T23:36:27.074") // sab
        ]
        XCTAssertEqual(sut.mostCommonDay(from: dates), "sábado")
    }

    @MainActor
    func testMostCommonDay_whenSundayIsTheTopOne_thenSundayIsReturned() async throws {
        let dates: [Date] = [
            date(from: "2023-01-07T23:36:27.074"), // sab
            date(from: "2023-01-08T23:36:27.074"), // dom
            date(from: "2023-01-11T23:36:27.074"), // qua
            date(from: "2023-02-03T23:36:27.074"), // sex
            date(from: "2023-02-18T23:36:27.074"), // sab
            date(from: "2023-03-25T23:36:27.074"), // sab
            date(from: "2023-03-31T23:36:27.074"), // sex
            date(from: "2023-04-16T23:36:27.074"), // dom
            date(from: "2023-04-22T23:36:27.074"), // sab
            date(from: "2023-06-11T23:36:27.074"), // dom
            date(from: "2023-07-27T23:36:27.074"), // qui
            date(from: "2023-08-16T23:36:27.074"), // qua
            date(from: "2023-08-17T23:36:27.074"), // qui
            date(from: "2023-08-22T23:36:27.074"), // ter
            date(from: "2023-09-05T23:36:27.074"), // ter
            date(from: "2023-09-06T23:36:27.074"), // qua
            date(from: "2023-09-15T23:36:27.074"), // sex
            date(from: "2023-09-24T23:36:27.074"), // dom
            date(from: "2023-09-26T23:36:27.074"), // ter
            date(from: "2023-09-29T23:36:27.074"), // sex
            date(from: "2023-10-01T23:36:27.074"), // dom
            date(from: "2023-10-10T23:36:27.074"), // ter
            date(from: "2023-10-13T23:36:27.074"), // sex
            date(from: "2023-10-19T23:36:27.074"), // qui
            date(from: "2023-10-21T23:36:27.074"), // sab
            date(from: "2023-10-01T23:36:27.074")  // dom
        ]

        XCTAssertEqual(sut.mostCommonDay(from: dates), "domingo")
    }

    func testMostCommonDay_whenSundayFridayAndSaturdayAreTied_thenFridayIsReturned() async throws {
        let dates: [Date] = [
            date(from: "2023-01-07T23:36:27.074"), // sab
            date(from: "2023-01-08T23:36:27.074"), // dom
            date(from: "2023-01-11T23:36:27.074"), // qua
            date(from: "2023-02-03T23:36:27.074"), // sex
            date(from: "2023-02-18T23:36:27.074"), // sab
            date(from: "2023-03-25T23:36:27.074"), // sab
            date(from: "2023-03-31T23:36:27.074"), // sex
            date(from: "2023-04-16T23:36:27.074"), // dom
            date(from: "2023-04-22T23:36:27.074"), // sab
            date(from: "2023-06-11T23:36:27.074"), // dom
            date(from: "2023-07-27T23:36:27.074"), // qui
            date(from: "2023-08-16T23:36:27.074"), // qua
            date(from: "2023-08-17T23:36:27.074"), // qui
            date(from: "2023-08-22T23:36:27.074"), // ter
            date(from: "2023-09-05T23:36:27.074"), // ter
            date(from: "2023-09-06T23:36:27.074"), // qua
            date(from: "2023-09-15T23:36:27.074"), // sex
            date(from: "2023-09-24T23:36:27.074"), // dom
            date(from: "2023-09-26T23:36:27.074"), // ter
            date(from: "2023-09-29T23:36:27.074"), // sex
            date(from: "2023-10-01T23:36:27.074"), // dom
            date(from: "2023-10-10T23:36:27.074"), // ter
            date(from: "2023-10-13T23:36:27.074"), // sex
            date(from: "2023-10-19T23:36:27.074"), // qui
            date(from: "2023-10-21T23:36:27.074")  // sab
        ]

        guard let days = await sut.mostCommonDay(from: dates) else {
            return XCTFail("Days should not be nil.")
        }

        XCTAssertTrue(days.contains("sexta-feira"))
        XCTAssertTrue(days.contains("sábado"))
        XCTAssertTrue(days.contains("domingo"))
    }
}

// MARK: - Version Is Allowed To Display Retro
//extension RetroViewModelTests {
//
//    func testVersionIsAllowedToDisplayRetro_whenVersionIsNotSet_shouldReturnFalse() async throws {
//        let stub: NetworkRabbitStub = .init()
//        // Not setting retro version; it will return nil.
//        let result = await RetroView.ViewModel.versionIsAllowedToDisplayRetro(
//            currentVersion: "7.5",
//            network: stub
//        )
//        XCTAssertFalse(result)
//    }
//
//    func testVersionIsAllowedToDisplayRetro_whenVersionIsSetAllowsAndIsTheSame_shouldReturnTrue() async throws {
//        let stub: NetworkRabbitStub = .init()
//        stub.retroStartingVersion = "7.5"
//        let result = await RetroView.ViewModel.versionIsAllowedToDisplayRetro(
//            currentVersion: "7.5",
//            network: stub
//        )
//        XCTAssertTrue(result)
//    }
//
//    func testVersionIsAllowedToDisplayRetro_whenVersionIsSetAllowsButIsDifferent_shouldReturnTrue() async throws {
//        let stub: NetworkRabbitStub = .init()
//        stub.retroStartingVersion = "7.5"
//        let result = await RetroView.ViewModel.versionIsAllowedToDisplayRetro(
//            currentVersion: "7.5.1",
//            network: stub
//        )
//        XCTAssertTrue(result)
//    }
//
//    func testVersionIsAllowedToDisplayRetro_whenVersionIsSetButDoesNotAllow_shouldReturnFalse() async throws {
//        let stub: NetworkRabbitStub = .init()
//        stub.retroStartingVersion = "99"
//        let result = await RetroView.ViewModel.versionIsAllowedToDisplayRetro(
//            currentVersion: "7.5",
//            network: stub
//        )
//        XCTAssertFalse(result)
//    }
//}

// MARK: - Version Is Allowed To Display Retro
extension RetroViewModelTests {

    @MainActor
    func testAnalyticsString_whenInformationLoadsCorrectly_shouldReturnAllDataFormatted() async throws {
        localDatabase.topSharedSounds = [
            .init(rankNumber: "1", contentName: "Conversa de bêbado"),
            .init(rankNumber: "2", contentName: "Exatamenti"),
            .init(rankNumber: "3", contentName: "Eu não aguento maaais"),
            .init(rankNumber: "4", contentName: "Puta que pariu, Marquinho"),
            .init(rankNumber: "5", contentName: "Vocês estão de sacanagem")
        ]
        localDatabase.shareCount = 20
        localDatabase.shareDates = [
            date(from: "2023-11-20T23:36:27.074")
        ]

        await sut.onViewLoaded()

        XCTAssertEqual(
            sut.analyticsString(),
            "1 Conversa de bêbado, 2 Exatamenti, 3 Eu não aguento maaais, 4 Puta que pariu, Marquinho, 5 Vocês estão de sacanagem; 20 compart; segunda-feira"
        )
    }
}
