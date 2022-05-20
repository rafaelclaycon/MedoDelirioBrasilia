import Combine
import UIKit

class MainViewViewModel: ObservableObject {
    
    @Published var sounds: [Sound]
    
    init(sounds: [Sound]) {
        self.sounds = sounds
    }
    
    func playSound(fromPath filepath: String) {
        guard filepath.isEmpty == false else {
            return
        }
        
        let path = Bundle.main.path(forResource: filepath, ofType: nil)!
        let url = URL(fileURLWithPath: path)

        print(url)

        player = AudioPlayer(url: url, update: { state in
            print(state?.activity as Any)
        })
        
        player?.togglePlay()
    }

    func shareSound(withPath filepath: String) {
        guard filepath.isEmpty == false else {
            return
        }
        
        let path = Bundle.main.path(forResource: filepath, ofType: nil)!
        let url = URL(fileURLWithPath: path)
        
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.rootViewController?.present(activityVC, animated: true, completion: nil)
        }
    }

}
