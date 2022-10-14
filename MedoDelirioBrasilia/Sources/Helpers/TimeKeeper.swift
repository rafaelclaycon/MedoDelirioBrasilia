import Foundation

class TimeKeeper {

    static func checkTwoMinutesHasPassed(_ originalDate: Date) -> Bool {
        let diffComponents = Calendar.current.dateComponents([.hour, .minute], from: originalDate, to: Date.now)
        let hours = diffComponents.hour!
        let minutes = diffComponents.minute!
        return hours > 0 || minutes >= 2
    }
    
    static func getDateAsString(addingDays daysToAdd: Int, referenceDate: Date = Date.now) -> String {
        var dayComponent = DateComponents()
        dayComponent.day = daysToAdd
        let newDate = Calendar.current.date(byAdding: dayComponent, to: referenceDate)
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "yyyy-MM-dd"
        if let newDate = newDate {
            return formatter3.string(from: newDate)
        } else {
            return .empty
        }
    }

}
