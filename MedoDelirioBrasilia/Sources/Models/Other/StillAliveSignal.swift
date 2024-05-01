import Foundation

struct StillAliveSignal: Hashable, Codable {

    var installId: String
    var modelName: String
    var systemName: String
    var systemVersion: String
    var isiOSAppOnMac: Bool
    var appVersion: String
    var currentTimeZone: String
    var dateTime: String

}
