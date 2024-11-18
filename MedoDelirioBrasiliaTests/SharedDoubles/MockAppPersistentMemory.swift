//
//  MockAppPersistentMemory.swift
//  MedoDelirioBrasiliaTests
//
//  Created by Rafael Schmitt on 30/10/24.
//

import Foundation
@testable import MedoDelirio

final class MockAppPersistentMemory: AppPersistentMemoryProtocol {

    var folderResearchHashValue: [String: String]? = nil
    var hasSentFolderResearchInfo = false
    var lastFolderResearchSyncDateTimeValue: Date? = nil

    var customInstallId: String = ""

    func folderResearchHashes() -> [String: String]? {
        return folderResearchHashValue
    }
    
    func folderResearchHashes(_ hashes: [String: String]) {
        folderResearchHashValue = hashes
    }
    
    func getHasSentFolderResearchInfo() -> Bool {
        return hasSentFolderResearchInfo
    }
    
    func setHasSentFolderResearchInfo(to newValue: Bool) {
        hasSentFolderResearchInfo = newValue
    }

    func lastFolderResearchSyncDateTime() -> Date? {
        lastFolderResearchSyncDateTimeValue
    }

    func lastFolderResearchSyncDateTime(_ dateTime: Date) {
        lastFolderResearchSyncDateTimeValue = dateTime
    }
}
