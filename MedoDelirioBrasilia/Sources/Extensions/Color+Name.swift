import SwiftUI

public extension Color {

    var name: String? {
        switch self {
        case Color.pastelBabyBlue:
            return "pastelBabyBlue"
        default:
            return nil
        }
    }

}
