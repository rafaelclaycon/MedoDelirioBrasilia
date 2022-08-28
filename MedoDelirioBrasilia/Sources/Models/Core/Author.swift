import Foundation

struct Author: Hashable, Codable, Identifiable {

    let id: String
    let name: String
    let photo: String?
    
    init(id: String, name: String, photo: String? = nil) {
        self.id = id
        self.name = name
        self.photo = photo
    }

}
