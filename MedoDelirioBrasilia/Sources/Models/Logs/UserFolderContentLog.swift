//
//  UserFolderContentLog.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 24/10/22.
//

import Foundation

struct UserFolderContentLog: Hashable, Codable, Identifiable {

    var id: String
    var userFolderLogId: String
    var contentId: String
    
    init(id: String = UUID().uuidString,
         userFolderLogId: String,
         contentId: String) {
        self.id = id
        self.userFolderLogId = userFolderLogId
        self.contentId = contentId
    }

}
