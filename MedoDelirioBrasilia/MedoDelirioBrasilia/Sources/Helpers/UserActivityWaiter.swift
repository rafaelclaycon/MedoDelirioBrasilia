import Foundation

/// Waiter as in the person who waits tables.
class UserActivityWaiter {
    
    static func getDonatableActivity(withType activityType: String, andTitle activityTitle: String) -> NSUserActivity {
        let currentActivity = NSUserActivity(activityType: activityType)
        currentActivity.title = activityTitle
        currentActivity.isEligibleForHandoff = false
        currentActivity.isEligibleForPrediction = true
        currentActivity.persistentIdentifier = UUID().uuidString
        return currentActivity
    }
    
}
