import Foundation

struct StillAliveSignal: Hashable, Codable {

    var installId: String
    var systemName: String
    var systemVersion: String
    var isiOSAppOnMac: Bool
    var currentTimeZone: String
    var dateTime: Date

}
