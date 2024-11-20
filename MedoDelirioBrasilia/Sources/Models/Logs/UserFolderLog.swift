//
//  UserFolderLog.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 24/10/22.
//

import Foundation

struct UserFolderLog: Hashable, Codable, Identifiable {

    var id: String
    var installId: String
    var folderId: String
    var folderSymbol: String
    var folderName: String
    var backgroundColor: String
    var logDateTime: String

    init(
        installId: String,
        folderId: String,
        folderSymbol: String,
        folderName: String,
        backgroundColor: String,
        logDateTime: String
    ) {
        self.id = UUID().uuidString
        self.installId = installId
        self.folderId = folderId
        self.folderSymbol = folderSymbol
        self.folderName = folderName
        self.backgroundColor = backgroundColor
        self.logDateTime = logDateTime
    }
}
