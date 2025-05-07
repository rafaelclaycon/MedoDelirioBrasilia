//
//  FakeAppPersistentMemory.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 30/10/24.
//

import Foundation

final class FakeAppPersistentMemory: AppPersistentMemoryProtocol {

    var folderResearchHashValue: [String: String]? = nil
    var hasSentFolderResearchInfo = false
    var lastFolderResearchSyncDateTimeValue: Date? = nil
    var hasDismissedJoinFolderResearchBanner = false

    var customInstallId: String = ""

    private var internalRecentSearches: [String] = []

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

    func getHasDismissedJoinFolderResearchBanner() -> Bool? {
        hasDismissedJoinFolderResearchBanner
    }

    func hasSeenVersion9WhatsNewScreen() -> Bool {
        false
    }

    func hasSeenVersion9WhatsNewScreen(_ newValue: Bool) {
        //
    }

    func saveRecentSearches(_ searchTerms: [String]) {
        internalRecentSearches = searchTerms
    }

    func recentSearches() -> [String]? {
        internalRecentSearches
    }
}
