import Combine
import UIKit

class MainViewViewModel: ObservableObject {
    
    @Published var sounds: [Sound]
    
    init(sounds: [Sound]) {
        self.sounds = sounds
    }

    func shareSound() {
        print("Share tapped")
    }

}
