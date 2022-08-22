import Foundation
import UIKit

/// The alternate app icons available for this app to use.
///
/// These raw values match the names in the app's project settings under
/// `ASSETCATALOG_COMPILER_APPICON_NAME` and `ASSETCATALOG_COMPILER_ALTERNATE_APPICON_NAMES`.
enum Icon: String, CaseIterable, Identifiable {

    case primary    = "AppIcon"
    case odioNojo   = "AppIcon-OdioNojo"
//    case green      = "AppIcon-Green"
//    case orange     = "AppIcon-Orange"
//    case purple     = "AppIcon-Purple"
//    case pink       = "AppIcon-Pink"
//    case teal       = "AppIcon-Teal"
//    case yellow     = "AppIcon-Yellow"

    var id: String { self.rawValue }

}

class AppIcon: ObservableObject, Equatable {

    @Published var appIcon: Icon = .primary

    static func == (lhs: AppIcon, rhs: AppIcon) -> Bool {
        return lhs.appIcon == rhs.appIcon
    }

    /// Change the app icon.
    /// - Tag: setAlternateAppIcon
    func setAlternateAppIcon(icon: Icon) {
            // Set the icon name to nil to use the primary icon.
            let iconName: String? = (icon != .primary) ? icon.rawValue : nil

            // Avoid setting the name if the app already uses that icon.
            guard UIApplication.shared.alternateIconName != iconName else { return }

            UIApplication.shared.setAlternateIconName(iconName) { (error) in
                if let error = error {
                    print("Failed request to update the app’s icon: \(error)")
                }
            }

            appIcon = icon
    }

    /// Initializes the model with the current state of the app's icon.
    init() {
        let iconName = UIApplication.shared.alternateIconName

        if iconName == nil {
            appIcon = .primary
        } else {
            appIcon = Icon(rawValue: iconName!)!
        }
    }

}
