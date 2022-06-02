import Foundation

struct ServerShareCountStat: Hashable, Codable {

    var installId: String
    var contentId: String
    var contentType: Int
    var shareCount: Int

}

struct ServerShareDestinationStat: Hashable, Codable {

    var installId: String
    var whatsAppCount: Int
    var telegramCount: Int
    var otherCount: Int

}

struct ServerShareBundleIdLog: Hashable, Codable {

    var bundleIds: [String]

}
