import Foundation

struct UserShareLog: Hashable, Codable, Identifiable {

    var id: String
    var installId: String
    var contentId: String
    var contentType: Int
    var dateTime: Date
    var destination: Int
    var destinationBundleId: String
    var sentToServer: Bool
    
    init(id: String = UUID().uuidString,
         installId: String,
         contentId: String,
         contentType: Int,
         dateTime: Date,
         destination: Int,
         destinationBundleId: String,
         sentToServer: Bool = false) {
        self.id = id
        self.installId = installId
        self.contentId = contentId
        self.contentType = contentType
        self.dateTime = dateTime
        self.destination = destination
        self.destinationBundleId = destinationBundleId
        self.sentToServer = sentToServer
    }

}

enum ContentType: Int {
    
    case sound, song
    
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
