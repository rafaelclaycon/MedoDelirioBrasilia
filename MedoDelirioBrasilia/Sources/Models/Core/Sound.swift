import Foundation

struct Sound: Hashable, Codable, Identifiable {

    var id: String
    var title: String
    var authorIds: [String]
    var authorName: String?
    var description: String
    var filename: String
    var dateAdded: Date?
    let isOffensive: Bool
    
    init(id: String = UUID().uuidString,
         title: String,
         authorIds: [String] = [UUID().uuidString],
         description: String = "",
         filename: String = "",
         dateAdded: Date? = Date(),
         isOffensive: Bool = false) {
        self.id = id
        self.title = title
        self.authorIds = authorIds
        self.description = description
        self.filename = filename
        self.dateAdded = dateAdded
        self.isOffensive = isOffensive
    }

}
