//
//  MockAppPersistentMemory.swift
//  MedoDelirioBrasiliaTests
//
//  Created by Rafael Schmitt on 30/10/24.
//

import Foundation
@testable import MedoDelirio

final class MockAppPersistentMemory: AppPersistentMemoryProtocol {

    var folderResearchHashValue: String? = nil
    var hasSentFolderResearchInfo = false

    func folderResearchHash() -> String? {
        return folderResearchHashValue
    }
    
    func folderResearchHash(_ hash: String) {
        folderResearchHashValue = hash
    }
    
    func getHasSentFolderResearchInfo() -> Bool {
        return hasSentFolderResearchInfo
    }
    
    func setHasSentFolderResearchInfo(to newValue: Bool) {
        hasSentFolderResearchInfo = newValue
    }
}
