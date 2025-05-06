import UIKit
import UserNotifications

class NotificationAide {

    static func registerForRemoteNotifications(completionHandler: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.sound, .alert]) { granted, error in
            if error == nil {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                UserSettings().setUserAllowedNotifications(to: granted)
                completionHandler(granted)
            } else {
                UserSettings().setUserAllowedNotifications(to: false)
                completionHandler(false)
            }
        }
    }
}
