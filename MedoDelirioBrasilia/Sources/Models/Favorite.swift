import Foundation

struct Favorite: Hashable, Codable {

    var contentId: String
    var dateAdded: Date
    
    init(contentId: String,
         dateAdded: Date = Date()) {
        self.contentId = contentId
        self.dateAdded = dateAdded
    }

}
