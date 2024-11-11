//
//  FakeFolderResearchRepository.swift
//  MedoDelirioBrasiliaTests
//
//  Created by Rafael Schmitt on 02/11/24.
//

import Foundation
@testable import MedoDelirio

final class FakeFolderResearchRepository: FolderResearchRepositoryProtocol {

    var didCallAdd = false

    var foldersContent: ([UserFolder], [UserFolderContent]?)?

    func add(
        folders: [UserFolder],
        content: [UserFolderContent]?,
        installId: String
    ) async throws {
        foldersContent = (folders, content)
        didCallAdd = true
    }
}
