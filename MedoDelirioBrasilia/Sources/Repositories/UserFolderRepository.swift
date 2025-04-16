//
//  UserFolderRepository.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 01/11/24.
//

import Foundation

protocol UserFolderRepositoryProtocol {

    func add(_ userFolder: UserFolder) throws

    func update(_ userFolder: UserFolder) throws

    func deleteUserContentFromFolder(withId folderId: String, contentId: String) throws

    /// Should only be used once.
    func addHashToExistingFolders() throws
}

final class UserFolderRepository: UserFolderRepositoryProtocol {

    private let database: LocalDatabaseProtocol

    // MARK: - Initializer

    init(
        database: LocalDatabaseProtocol
    ) {
        self.database = database
    }

    func add(_ userFolder: UserFolder) throws {
        var newFolder = userFolder
        newFolder.changeHash = FolderResearchProvider.hash(userFolder.folderHash([]))
        try database.insert(newFolder)
    }

    func update(_ userFolder: UserFolder) throws {
        var folder = userFolder
        let contents = try database.contentsInside(userFolder: folder.id)
        folder.changeHash = folder.folderHash(contents.map { $0.contentId })
        try database.update(folder)
    }

    func deleteUserContentFromFolder(withId folderId: String, contentId: String) throws {
        try database.deleteUserContentFromFolder(withId: folderId, contentId: contentId)
    }

    func addHashToExistingFolders() throws {
        let folders = try database.allFolders()
        try folders.forEach { try update($0) }
    }
}
