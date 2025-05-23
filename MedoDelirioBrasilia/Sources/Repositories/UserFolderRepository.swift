//
//  UserFolderRepository.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 01/11/24.
//

import Foundation

protocol UserFolderRepositoryProtocol {

    func allFolders() async throws -> [UserFolder]

    func add(_ userFolder: UserFolder) throws
    func insert(contentId: String, intoUserFolder userFolderId: String) throws
    func contentExistsInsideUserFolder(withId folderId: String, contentId: String) throws -> Bool

    func update(_ userFolder: UserFolder) throws

    func delete(_ folderId: String) throws
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

    func allFolders() async throws -> [UserFolder] {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                continuation.resume(returning: try database.allFolders())
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    func add(_ userFolder: UserFolder) throws {
        var newFolder = userFolder
        newFolder.changeHash = FolderResearchProvider.hash(userFolder.folderHash([]))
        try database.insert(newFolder)
    }

    func insert(contentId: String, intoUserFolder userFolderId: String) throws {
        try database.insert(contentId: contentId, intoUserFolder: userFolderId)
    }

    func contentExistsInsideUserFolder(withId folderId: String, contentId: String) throws -> Bool {
        try database.contentExistsInsideUserFolder(withId: folderId, contentId: contentId)
    }

    func update(_ userFolder: UserFolder) throws {
        var folder = userFolder
        let contents = try database.contentsInside(userFolder: folder.id)
        folder.changeHash = folder.folderHash(contents.map { $0.contentId })
        try database.update(folder)
    }

    func delete(_ folderId: String) throws {
        try database.deleteUserFolder(withId: folderId)
    }

    func deleteUserContentFromFolder(withId folderId: String, contentId: String) throws {
        try database.deleteUserContentFromFolder(withId: folderId, contentId: contentId)
    }

    func addHashToExistingFolders() throws {
        let folders = try database.allFolders()
        try folders.forEach { try update($0) }
    }
}
