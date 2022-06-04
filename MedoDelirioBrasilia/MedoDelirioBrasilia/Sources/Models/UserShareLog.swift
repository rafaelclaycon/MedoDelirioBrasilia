import Foundation

struct UserShareLog: Hashable, Codable {

    var installId: String
    var contentId: String
    var contentType: Int
    var dateTime: Date
    var destination: Int
    var destinationBundleId: String
    var sentToServer: Bool

}

enum ContentType: Int {
    
    case sound,song
    
}

enum ShareDestination: Int {
    
    case whatsApp, telegram, other
    
    static func translateFrom(activityTypeRawValue: String) -> ShareDestination {
        if activityTypeRawValue.contains("WhatsApp") {
            return .whatsApp
        } else if activityTypeRawValue.contains("Telegraph") {
            return .telegram
        } else {
            return .other
        }
    }
    
}
