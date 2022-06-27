import Combine

class AddToFolderViewViewModel: ObservableObject {

    @Published var folders = [UserFolder]()
    @Published var hasFoldersToDisplay: Bool = false
    
    // Alerts
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    
    func reloadFolderList(withFolders outsideFolders: [UserFolder]?) {
        guard let actualFolders = outsideFolders, actualFolders.count > 0 else {
            return
        }
        self.folders = actualFolders
        self.hasFoldersToDisplay = true
    }
    
    func soundIsNotYetOnFolder(folderId: String, contentId: String) -> Bool {
        var contentExistsInsideUserFolder = true
        do {
            contentExistsInsideUserFolder = try database.contentExistsInsideUserFolder(withId: folderId, contentId: contentId)
        } catch {
            return true
        }
        return contentExistsInsideUserFolder == false
    }
    
    // MARK: - Alerts
    
    func showSoundAlredyInFolderAlert(folderName: String) {
        alertTitle = "Já Adicionado"
        alertMessage = "Esse som já está na pasta \"\(folderName)\"."
        showAlert = true
    }

}
