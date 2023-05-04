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
    
    func contentExistsInsideUserFolder(withId folderId: String, contentId: String) throws -> Bool {
        guard let content = contentInsideFolder else {
            return false
        }
        return content.contains(contentId)
    }
    
    func insert(sound newSound: MedoDelirio.Sound) throws {
        print("insert(sound) called.")
    }
}
