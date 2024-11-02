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
}

final class UserFolderRepository: UserFolderRepositoryProtocol {

    private let database: LocalDatabase

    // MARK: - Initializer

    init(
        database: LocalDatabase = LocalDatabase()
    ) {
        self.database = database
    }

    func add(_ userFolder: UserFolder) throws {
        try database.insert(userFolder)
    }

    func update(_ userFolder: UserFolder) throws {
        try database.update(userFolder)
    }
}
