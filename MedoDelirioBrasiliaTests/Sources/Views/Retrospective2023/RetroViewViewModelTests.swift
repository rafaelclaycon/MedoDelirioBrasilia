//
//  RetroViewViewModelTests.swift
//  MedoDelirioBrasiliaTests
//
//  Created by Rafael Schmitt on 16/10/23.
//

@testable import MedoDelirio
import XCTest

final class RetroViewViewModelTests: XCTestCase {

    private var sut: RetroView.ViewModel!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = .init()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    private func date(from isoDate: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter.date(from: isoDate)!
    }

    func testDayOfTheWeekFromDate() throws {
        XCTAssertEqual(sut.dayOfTheWeek(from: date(from: "2023-10-16T23:36:27.074")), "segunda-feira")
    }

    func testMostCommonDay_whenNoDates_thenNilReturned() throws {
        let dates: [Date] = []
        XCTAssertNil(sut.mostCommonDay(from: dates))
    }

    func testMostCommonDay_whenOnlySingleDaySaturday_thenSaturdayIsReturned() throws {
        let dates: [Date] = [
            date(from: "2023-01-07T23:36:27.074") // sab
        ]
        XCTAssertEqual(sut.mostCommonDay(from: dates), "sábado")
    }

    func testMostCommonDay_whenSundayIsTheTopOne_thenSundayIsReturned() throws {
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

    func testMostCommonDay_whenSundayFridayAndSaturdayAreTied_thenFridayIsReturned() throws {
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

        guard let days = sut.mostCommonDay(from: dates) else {
            return XCTFail("Days should not be nil.")
        }

        XCTAssertTrue(days.contains("sexta-feira"))
        XCTAssertTrue(days.contains("sábado"))
        XCTAssertTrue(days.contains("domingo"))
    }
}

extension RetroViewViewModelTests {

    func testVersionIsAllowedToDisplayRetro_whenIsNotAllowed_shouldReturnFalse() throws {
        // sut.
    }
}
