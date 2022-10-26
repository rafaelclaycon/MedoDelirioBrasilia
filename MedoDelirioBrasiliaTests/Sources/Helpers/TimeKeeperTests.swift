@testable import MedoDelirio
import XCTest

final class TimeKeeperTests: XCTestCase {

    func test_checkTwoMinutesHasPassed_whenOriginalDateIsOneDayBefore_shouldReturnTrue() throws {
        var dayComponent = DateComponents()
        dayComponent.day = -1
        let calendar = Calendar.current
        let originalDate = calendar.date(byAdding: dayComponent, to: Date.now)!
        
        XCTAssertTrue(TimeKeeper.checkTwoMinutesHasPassed(originalDate))
    }
    
    func test_checkTwoMinutesHasPassed_whenOriginalDateIsAWeekBefore_shouldReturnTrue() throws {
        var dayComponent = DateComponents()
        dayComponent.day = -7
        let calendar = Calendar.current
        let originalDate = calendar.date(byAdding: dayComponent, to: Date.now)!
        
        XCTAssertTrue(TimeKeeper.checkTwoMinutesHasPassed(originalDate))
    }
    
    func test_checkTwoMinutesHasPassed_whenOriginalDateIsFiveMinutesAgo_shouldReturnTrue() throws {
        var dayComponent = DateComponents()
        dayComponent.minute = -5
        
        let originalDate = Calendar.current.date(byAdding: dayComponent, to: Date.now)!
        
        XCTAssertTrue(TimeKeeper.checkTwoMinutesHasPassed(originalDate))
    }
    
    func test_checkTwoMinutesHasPassed_whenOriginalDateIsOneMinutesAgo_shouldReturnFalse() throws {
        var dayComponent = DateComponents()
        dayComponent.minute = -1
        
        let originalDate = Calendar.current.date(byAdding: dayComponent, to: Date.now)!
        
        XCTAssertFalse(TimeKeeper.checkTwoMinutesHasPassed(originalDate))
    }
    
    func test_checkTwoMinutesHasPassed_whenOriginalDateIsExactlyTwoMinutesAgo_shouldReturnTrue() throws {
        var dayComponent = DateComponents()
        dayComponent.minute = -2
        
        let originalDate = Calendar.current.date(byAdding: dayComponent, to: Date.now)!
        
        XCTAssertTrue(TimeKeeper.checkTwoMinutesHasPassed(originalDate))
    }
    
    func test_getDateAsStringAddingDays_whenDaysIsMinusSeven_shouldReturnCorrectDate() throws {
        let isoDate = "2022-10-12T10:17:00+0000"

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from: isoDate)!
        
        XCTAssertEqual(TimeKeeper.getDateAsString(addingDays: -7, referenceDate: date), "2022-10-05")
    }
    
    func test_getDateAsStringAddingDays_whenDaysIsMinusThirty_shouldReturnCorrectDate() throws {
        let isoDate = "2022-10-12T10:17:00+0000"

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from: isoDate)!
        
        XCTAssertEqual(TimeKeeper.getDateAsString(addingDays: -30, referenceDate: date), "2022-09-12")
    }

}
