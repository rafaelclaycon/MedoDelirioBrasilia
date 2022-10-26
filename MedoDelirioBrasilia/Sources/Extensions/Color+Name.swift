import SwiftUI

public extension Color {

    var name: String? {
        switch self {
        case .pastelPurple:
            return "pastelPurple"
        case .pastelBabyBlue:
            return "pastelBabyBlue"
        case .pastelBrightGreen:
            return "pastelBrightGreen"
        case .pastelYellow:
            return "pastelYellow"
        case .pastelOrange:
            return "pastelOrange"
        case .pastelPink:
            return "pastelPink"
        case .pastelGray:
            return "pastelGray"
        case .pastelRoyalBlue:
            return "pastelRoyalBlue"
        case .pastelMutedGreen:
            return "pastelMutedGreen"
        case .pastelRed:
            return "pastelRed"
        case .pastelBeige:
            return "pastelBeige"
        default:
            return nil
        }
    }

}
