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

}
