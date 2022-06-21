import Foundation

struct UserFolder: Hashable, Codable, Identifiable {

    var id: String
    var symbol: String
    var title: String
    var backgroundColor: String
    
    init(id: String = UUID().uuidString,
         symbol: String,
         title: String,
         backgroundColor: String) {
        self.id = id
        self.symbol = symbol
        self.title = title
        self.backgroundColor = backgroundColor
    }

}
