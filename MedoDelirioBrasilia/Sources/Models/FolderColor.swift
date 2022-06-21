import SwiftUI

struct FolderColor: Identifiable {

    var id: String
    var color: Color
    
    init(id: String = UUID().uuidString,
         color: Color) {
        self.id = id
        self.color = color
    }

}
