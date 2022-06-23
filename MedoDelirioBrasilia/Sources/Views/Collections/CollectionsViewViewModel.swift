import Combine
import UIKit

class CollectionsViewViewModel: ObservableObject {

    @Published var collections = [ContentCollection]()
    
    @Published var folders = [UserFolder]()
    @Published var hasFoldersToDisplay: Bool = false
    
    func reloadCollectionList(withCollections outsideCollections: [ContentCollection]?) {
        guard let actualCollections = outsideCollections, actualCollections.count > 0 else {
            return
        }
        self.collections = actualCollections
    }
    
    func reloadFolderList(withFolders outsideFolders: [UserFolder]?) {
        guard let actualFolders = outsideFolders, actualFolders.count > 0 else {
            return
        }
        self.folders = actualFolders
        self.hasFoldersToDisplay = true
    }

}
