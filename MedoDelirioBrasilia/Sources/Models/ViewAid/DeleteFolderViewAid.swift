import Foundation

struct DeleteFolderViewAid {

    var alertTitle: String
    var alertMessage: String
    var showAlert: Bool
    var folderIdForDeletion: String
    
    init() {
        self.alertTitle = .empty
        self.alertMessage = .empty
        self.showAlert = false
        self.folderIdForDeletion = .empty
    }

}