import Foundation

struct Sound: Hashable, Codable, Identifiable {

    var id: String
    var title: String
    var authorId: String
    var authorName: String?
    var description: String
    var filename: String
    var dateAdded: Date?
    
    init(id: String = UUID().uuidString,
         title: String,
         authorId: String,
         description: String = "",
         filename: String = "",
         dateAdded: Date = Date()) {
        self.id = id
        self.title = title
        self.authorId = authorId
        //self.authorName = authorData.first(where: { $0.id == authorId })?.name
        self.description = description
        self.filename = filename
        self.dateAdded = dateAdded
    }

}
