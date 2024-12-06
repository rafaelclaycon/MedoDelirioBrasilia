//
//  DateExtensionTests.swift
//  MedoDelirioBrasiliaTests
//
//  Created by Rafael Schmitt on 11/10/22.
//

@testable import MedoDelirio
import XCTest

final class DateExtensionTests: XCTestCase {

    func test_checkOneMinuteHasPassed_whenOriginalDateIsOneDayBefore_shouldReturnTrue() throws {
        var dayComponent = DateComponents()
        dayComponent.day = -1
        let calendar = Calendar.current
        let originalDate = calendar.date(byAdding: dayComponent, to: .now)!
        
        XCTAssertTrue(originalDate.minutesPassed(1))
    }

    func test_checkOneMinuteHasPassed_whenOriginalDateIsAWeekBefore_shouldReturnTrue() throws {
        var dayComponent = DateComponents()
        dayComponent.day = -7
        let calendar = Calendar.current
        let originalDate = calendar.date(byAdding: dayComponent, to: .now)!
        
        XCTAssertTrue(originalDate.minutesPassed(1))
    }

    func test_checkOneMinuteHasPassed_whenOriginalDateIsFiveMinutesAgo_shouldReturnTrue() throws {
        var dayComponent = DateComponents()
        dayComponent.minute = -5
        
        let originalDate = Calendar.current.date(byAdding: dayComponent, to: .now)!
        
        XCTAssertTrue(originalDate.minutesPassed(1))
    }

    func test_checkOneMinuteHasPassed_whenOriginalDateIsHalfAMinuteAgo_shouldReturnFalse() throws {
        var dayComponent = DateComponents()
        dayComponent.second = -30

        let originalDate = Calendar.current.date(byAdding: dayComponent, to: .now)!
        
        XCTAssertFalse(originalDate.minutesPassed(1))
    }

    func test_checkOneMinuteHasPassed_whenOriginalDateIsExactlyOneMinuteAgo_shouldReturnTrue() throws {
        var dayComponent = DateComponents()
        dayComponent.minute = -1

        let originalDate = Calendar.current.date(byAdding: dayComponent, to: .now)!
        
        XCTAssertTrue(originalDate.minutesPassed(1))
    }

    func test_getDateAsStringAddingDays_whenDaysIsMinusSeven_shouldReturnCorrectDate() throws {
        let isoDate = "2022-10-12T10:17:00+0000"

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from: isoDate)!
        
        XCTAssertEqual(Date.dateAsString(addingDays: -7, referenceDate: date), "2022-10-05")
    }

    func test_getDateAsStringAddingDays_whenDaysIsMinusThirty_shouldReturnCorrectDate() throws {
        let isoDate = "2022-10-12T10:17:00+0000"

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from: isoDate)!
        
        XCTAssertEqual(Date.dateAsString(addingDays: -30, referenceDate: date), "2022-09-12")
    }

    func testMinutesPassed_whenOriginalDateIsFiveMinutesAgo_shouldReturnFalse() throws {
        var dayComponent = DateComponents()
        dayComponent.minute = -5

        let originalDate = Calendar.current.date(byAdding: dayComponent, to: .now)!

        XCTAssertFalse(originalDate.minutesPassed(60))
    }

    func testMinutesPassed_whenOriginalDateIsOneWeekAgo_shouldReturnTrue() throws {
        var dayComponent = DateComponents()
        dayComponent.day = -7
        let calendar = Calendar.current
        let originalDate = calendar.date(byAdding: dayComponent, to: .now)!

        XCTAssertTrue(originalDate.minutesPassed(60))
    }

    func testMinutesPassed_whenOriginalDateIsExactlyOneHourAgo_shouldReturnTrue() throws {
        var dayComponent = DateComponents()
        dayComponent.hour = -1
        let calendar = Calendar.current
        let originalDate = calendar.date(byAdding: dayComponent, to: .now)!

        XCTAssertTrue(originalDate.minutesPassed(60))
    }
}
