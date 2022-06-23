import Foundation

struct UserFolderContent: Hashable, Codable {

    var userFolderId: String
    var contentId: String
    
    init(userFolderId: String,
         contentId: String) {
        self.userFolderId = userFolderId
        self.contentId = contentId
    }

}
