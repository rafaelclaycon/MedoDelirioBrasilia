import Combine

class AddToFolderViewViewModel: ObservableObject {

    @Published var folders = [UserFolder]()
    @Published var hasFoldersToDisplay: Bool = false
    
    func reloadFolderList(withFolders outsideFolders: [UserFolder]?) {
        guard let actualFolders = outsideFolders, actualFolders.count > 0 else {
            return
        }
        self.folders = actualFolders
        self.hasFoldersToDisplay = true
    }

}
