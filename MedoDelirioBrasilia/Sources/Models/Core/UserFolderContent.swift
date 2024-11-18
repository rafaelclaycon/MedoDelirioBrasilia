//
//  UserFolderContent.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 28/06/22.
//

import Foundation

struct UserFolderContent: Hashable, Codable {

    var userFolderId: String
    var contentId: String
    var dateAdded: Date?
    
    init(
        userFolderId: String,
        contentId: String,
        dateAdded: Date? = nil
    ) {
        self.userFolderId = userFolderId
        self.contentId = contentId
        self.dateAdded = dateAdded
    }
}
