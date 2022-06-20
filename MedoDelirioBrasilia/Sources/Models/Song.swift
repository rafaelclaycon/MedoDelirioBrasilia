import Foundation

struct Song: Hashable, Codable, Identifiable {

    var id: String
    var title: String
    var description: String
    var filename: String
    var dateAdded: Date?
    let isOffensive: Bool
    
    init(id: String = UUID().uuidString,
         title: String,
         description: String = "",
         filename: String = "",
         dateAdded: Date = Date(),
         isOffensive: Bool = false) {
        self.id = id
        self.title = title
        self.description = description
        self.filename = filename
        self.dateAdded = dateAdded
        self.isOffensive = isOffensive
    }

}
