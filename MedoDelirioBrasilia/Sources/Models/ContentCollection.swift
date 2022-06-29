import Foundation

struct ContentCollection: Hashable, Codable, Identifiable {

    var id: String
    var title: String
    var imageURL: String
    
    init(id: String = UUID().uuidString,
         title: String,
         imageURL: String) {
        self.id = id
        self.title = title
        self.imageURL = imageURL
    }

}
