import Foundation

struct Sound: Hashable, Codable, Identifiable {

    var id: String
    var title: String
    var author: String
    var filename: String
    
    init(id: String = UUID().uuidString,
         title: String,
         author: String,
         filename: String = "") {
        self.id = id
        self.title = title
        self.author = author
        self.filename = filename
    }

}
