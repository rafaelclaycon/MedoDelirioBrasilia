//
//  UserFolderRepository.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 01/11/24.
//

import Foundation

protocol UserFolderRepositoryProtocol {

    // Create

    func add(_ userFolder: UserFolder) throws
    func add(sounds: [Sound], into folderId: String) throws

    // Read

    func allFolders() throws -> [UserFolder]

    // Update

    func update(_ userFolder: UserFolder) throws
    /// Should only be used once.
    func addHashToExistingFolders() throws

    // Delete
}

final class UserFolderRepository: UserFolderRepositoryProtocol {

    private let database: LocalDatabase

    // MARK: - Initializer

    init(
        database: LocalDatabase = LocalDatabase()
    ) {
        self.database = database
    }
}

// MARK: - Create

extension UserFolderRepository {

    func add(_ userFolder: UserFolder) throws {
        var newFolder = userFolder
        newFolder.name = newFolder.name.trimmingCharacters(in: .whitespacesAndNewlines)
        newFolder.changeHash = FolderResearchProvider.hash(userFolder.folderHash([]))
        try database.insert(newFolder)
    }

    func add(sounds: [Sound], into folderId: String) throws {
        try sounds.forEach { sound in
            try database.insert(contentId: sound.id, intoUserFolder: folderId)
        }
        // Update folder hash
    }
}

// MARK: - Read

extension UserFolderRepository {

    func allFolders() throws -> [UserFolder] {
        try database.allFolders()
    }
}

// MARK: - Update

extension UserFolderRepository {

    func update(_ userFolder: UserFolder) throws {
        var folder = userFolder
        let contents = try database.contentsInside(userFolder: folder.id)
        folder.name = folder.name.trimmingCharacters(in: .whitespacesAndNewlines)
        folder.changeHash = folder.folderHash(contents.map { $0.contentId })
        try database.update(folder)
    }

    func addHashToExistingFolders() throws {
        let folders = try database.allFolders()
        try folders.forEach { try update($0) }
    }
}
