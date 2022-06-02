import Foundation

struct ServerShareLog: Hashable, Codable {

    var installId: String
    var contentId: String
    var contentType: Int
    var shareCount: Int

}

struct ServerShareDestinationLog: Hashable, Codable {

    var installId: String
    var whatsAppCount: Int
    var telegramCount: Int
    var otherCount: Int

}

struct ServerShareBundleIdLog: Hashable, Codable {

    var bundleIds: [String]

}
