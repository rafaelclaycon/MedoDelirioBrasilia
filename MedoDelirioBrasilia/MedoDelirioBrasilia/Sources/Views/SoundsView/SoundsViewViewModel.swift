import Combine
import UIKit

class SoundsViewViewModel: ObservableObject {
    
    @Published var sounds: [Sound]
    @Published var sortOption: Int
    
    init(sounds: [Sound]) {
        self.sounds = sounds
        self.sortOption = 0 //UserSettings.getArchiveSortOption()
        
        for i in 0...(sounds.count - 1) {
            self.sounds[i].authorName = authorData.first(where: { $0.id == self.sounds[i].authorId })?.name ?? "Desconhecido"
        }
        
        self.sounds.sort(by: { $0.title.withoutDiacritics() < $1.title.withoutDiacritics() })
    }
    
    func playSound(fromPath filepath: String) {
        guard filepath.isEmpty == false else {
            return
        }
        
        let path = Bundle.main.path(forResource: filepath, ofType: nil)!
        let url = URL(fileURLWithPath: path)

        player = AudioPlayer(url: url, update: { state in
            //print(state?.activity as Any)
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
