//
//  LocalDatabaseStub.swift
//  MedoDelirioBrasiliaTests
//
//  Created by Rafael Claycon Schmitt on 02/02/23.
//

@testable import MedoDelirio
import Foundation

class LocalDatabaseStub: LocalDatabaseProtocol {

    var contentInsideFolder: [String]? = nil
    var didCallInsertSound = false
    var didCallUpdateSound = false
    var didCallDeleteSound = false
    var didCallMarkAsSucceeded = false
    var didCallInsertSyncLog = false
    var didCallSetIsFromServer = false
    var didCallInsertAuthor = false
    var didCallUpdateAuthor = false

    func contentExistsInsideUserFolder(withId folderId: String, contentId: String) throws -> Bool {
        guard let content = contentInsideFolder else {
            return false
        }
        return content.contains(contentId)
    }
    
    func insert(sound newSound: MedoDelirio.Sound) throws {
        didCallInsertSound = true
    }

    func update(sound updatedSound: MedoDelirio.Sound) throws {
        didCallUpdateSound = true
    }

    func delete(soundId: String) throws {
        didCallDeleteSound = true
    }

    func markAsSucceeded(updateEventId: UUID) throws {
        didCallMarkAsSucceeded = true
    }

    func insert(syncLog newSyncLog: MedoDelirio.SyncLog) {
        didCallInsertSyncLog = true
    }

    func setIsFromServer(to value: Bool, on soundId: String) throws {
        didCallSetIsFromServer = true
    }

    func insert(author newAuthor: MedoDelirio.Author) throws {
        didCallInsertAuthor = true
    }

    func update(author updatedAuthor: MedoDelirio.Author) throws {
        didCallUpdateAuthor = true
    }
}
