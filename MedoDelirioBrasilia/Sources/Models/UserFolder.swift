import Foundation

struct UserFolder: Hashable, Codable, Identifiable {

    var id: String
    var symbol: String
    var name: String
    var backgroundColor: String
    
    init(id: String = UUID().uuidString,
         symbol: String,
         name: String,
         backgroundColor: String) {
        self.id = id
        self.symbol = symbol
        self.name = name
        self.backgroundColor = backgroundColor
    }

}
