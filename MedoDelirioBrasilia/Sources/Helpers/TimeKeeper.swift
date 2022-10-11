import Foundation

class TimeKeeper {

    static func checkTwoMinutesHasPassed(_ originalDate: Date) -> Bool {
        let diffComponents = Calendar.current.dateComponents([.hour, .minute], from: originalDate, to: Date.now)
        let hours = diffComponents.hour!
        let minutes = diffComponents.minute!
        return hours > 0 || minutes >= 2
    }

}
