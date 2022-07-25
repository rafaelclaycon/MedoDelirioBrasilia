import Combine
import UIKit

class SidebarViewViewModel: ObservableObject {

    @Published var folders = [UserFolder]()
    
    func reloadFolderList(withFolders outsideFolders: [UserFolder]?) {
        guard let actualFolders = outsideFolders, actualFolders.count > 0 else {
            return self.folders.removeAll()
        }
        self.folders = actualFolders
    }

}
