import Foundation

struct Song: Hashable, Codable, Identifiable {

    var id: String
    var title: String
    var description: String
    var genre: String
    var duration: String
    var filename: String
    var dateAdded: Date?
    let isOffensive: Bool
    
    init(id: String = UUID().uuidString,
         title: String,
         description: String = "",
         genre: String = "",
         duration: String = "",
         filename: String = "",
         dateAdded: Date = Date(),
         isOffensive: Bool = false) {
        self.id = id
        self.title = title
        self.description = description
        self.genre = genre
        self.duration = duration
        self.filename = filename
        self.dateAdded = dateAdded
        self.isOffensive = isOffensive
    }

}
