import Foundation

struct UserFolder: Hashable, Codable, Identifiable {

    var id: String
    var symbol: String
    var title: String
    var backgroundColorR: Double
    var backgroundColorG: Double
    var backgroundColorB: Double
    
    init(id: String = UUID().uuidString,
         symbol: String,
         title: String,
         backgroundColorR: Double,
         backgroundColorG: Double,
         backgroundColorB: Double) {
        self.id = id
        self.symbol = symbol
        self.title = title
        self.backgroundColorR = backgroundColorR
        self.backgroundColorG = backgroundColorG
        self.backgroundColorB = backgroundColorB
    }

}
