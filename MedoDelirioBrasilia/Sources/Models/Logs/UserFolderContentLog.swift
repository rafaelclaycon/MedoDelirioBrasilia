//
//  UserFolderContentLog.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 24/10/22.
//

import Foundation

struct UserFolderContentLog: Hashable, Codable, Identifiable {

    let id: String
    let userFolderLogId: String
    let contentId: String

    init(
        userFolderLogId: String,
        contentId: String
    ) {
        self.id = UUID().uuidString
        self.userFolderLogId = userFolderLogId
        self.contentId = contentId
    }
}
