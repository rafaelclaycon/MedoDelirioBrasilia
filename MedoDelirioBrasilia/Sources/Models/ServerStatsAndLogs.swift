import Foundation

/// Logs sent to and from the server to generate audience statistics.
struct ServerShareCountStat: Hashable, Codable {

    var installId: String
    var contentId: String
    var contentType: Int
    var shareCount: Int
    var date: Date?

}

/// The client receives a ServerShareCountStat from the server and transforms it into this for local persistance.
struct AudienceShareCountStat: Hashable, Codable {

    var contentId: String
    var contentType: Int
    var shareCount: Int

}

/// Sent to the server. Goal: satisfy the developer's curiosity.
struct ServerShareDestinationStat: Hashable, Codable {

    var installId: String
    var whatsAppCount: Int
    var telegramCount: Int
    var otherCount: Int

}

/// Sent to the server. Goal: understand usage trends.
struct ServerShareBundleIdLog: Hashable, Codable {

    var bundleId: String
    var count: Int

}
