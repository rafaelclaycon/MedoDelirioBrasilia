import Foundation

enum PushNotificationType: String {

    case newEpisode = "new_episode"
}

extension Notification.Name {

    static let navigateToTab = Notification.Name("navigateToTab")
}

enum NavigateToTabKey {

    static let phoneTab = "phoneTab"
}
