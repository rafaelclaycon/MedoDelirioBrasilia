import Foundation

struct TopChartItem: Hashable, Codable, Identifiable {

    var id: String
    var contentId: String
    var contentName: String
    var contentAuthorId: String
    var contentAuthorName: String
    var shareCount: Int

}
