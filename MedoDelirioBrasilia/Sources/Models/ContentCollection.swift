import Foundation

struct ContentCollection: Hashable, Codable, Identifiable {

    var id: String
    var title: String
    
    init(id: String = UUID().uuidString,
         title: String) {
        self.id = id
        self.title = title
    }

}
