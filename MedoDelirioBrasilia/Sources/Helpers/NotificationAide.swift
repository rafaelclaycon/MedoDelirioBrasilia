import UIKit
import UserNotifications

class NotificationAide {

    static func registerForRemoteNotifications() async {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.sound, .alert])
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
            UserSettings().setUserAllowedNotifications(to: granted)
        } catch {
            UserSettings().setUserAllowedNotifications(to: false)
        }
    }
}
