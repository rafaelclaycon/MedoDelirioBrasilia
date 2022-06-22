import Foundation

struct StillAliveSignal: Hashable, Codable {

    var systemName: String
    var systemVersion: String
    var currentTimeZone: String
    var dateTime: Date

}
