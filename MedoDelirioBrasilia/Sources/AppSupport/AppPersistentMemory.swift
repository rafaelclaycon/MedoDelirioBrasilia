//
//  AppPersistentMemory.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 17/08/22.
//

import Foundation

protocol AppPersistentMemoryProtocol {

    func folderResearchHashes() -> [String: String]?
    func folderResearchHashes(_ foldersHashes: [String: String])

    /// This was used to mark sending before the more elaborate change syncing.
    func getHasSentFolderResearchInfo() -> Bool
    func setHasSentFolderResearchInfo(to newValue: Bool)
    func getHasDismissedJoinFolderResearchBanner() -> Bool?

    func lastFolderResearchSyncDateTime() -> Date?
    func lastFolderResearchSyncDateTime(_ dateTime: Date)

    var customInstallId: String { get }
}

/// Different from User Settings, App Memory are settings that help the app remember stuff to avoid asking again or doing a network job more than once per day.
final class AppPersistentMemory: AppPersistentMemoryProtocol {

    private let userDefaults: UserDefaults

    init(
        userDefaults: UserDefaults = UserDefaults.standard
    ) {
        self.userDefaults = userDefaults
    }
}

// MARK: - Getters

extension AppPersistentMemory {

    var customInstallId: String {
        guard let existingCustomDeviceID = userDefaults.object(forKey: "customInstallId") else {
            let newlyCreatedDeviceID = UUID().uuidString
            userDefaults.set(newlyCreatedDeviceID, forKey: "customInstallId")
            return newlyCreatedDeviceID
        }
        return String(existingCustomDeviceID as! String)
    }

    func getHasSentDeviceModelToServer() -> Bool {
        guard let value = userDefaults.object(forKey: "hasSentDeviceModelToServer") else {
            return false
        }
        return Bool(value as! Bool)
    }

    func getLastSendDateOfUserPersonalTrendsToServer() -> Date? {
        guard let value = userDefaults.object(forKey: "lastSendDateOfUserPersonalTrendsToServer") else {
            return nil
        }
        return Date(timeIntervalSince1970: value as! Double)
    }

    func getFolderBannerWasDismissed() -> Bool {
        guard let value = userDefaults.object(forKey: "folderBannerWasDismissed") else {
            return false
        }
        return Bool(value as! Bool)
    }

    func getShouldRetrySendingDevicePushToken() -> Bool {
        let userDefaults = UserDefaults.standard
        guard let value = userDefaults.object(forKey: "shouldRetrySendingDevicePushToken") else {
            return true
        }
        return Bool(value as! Bool)
    }

    func hasShownNotificationsOnboarding() -> Bool {
        guard let value = userDefaults.object(forKey: "hasShownNotificationsOnboarding") else {
            return false
        }
        return Bool(value as! Bool)
    }

    func getHasHiddenShareAsVideoTextSocialNetworkTip() -> Bool {
        guard let value = userDefaults.object(forKey: "hasHiddenShareAsVideoTwitterTip") else {
            return false
        }
        return Bool(value as! Bool)
    }

    func getHasHiddenShareAsVideoInstagramTip() -> Bool {
        guard let value = userDefaults.object(forKey: "hasHiddenShareAsVideoInstagramTip") else {
            return false
        }
        return Bool(value as! Bool)
    }

    func getHasDismissedJoinFolderResearchBanner() -> Bool? {
        guard let value = userDefaults.object(forKey: "hasDismissedJoinFolderResearchBanner") else {
            return nil
        }
        return Bool(value as! Bool)
    }

    func getHasSentFolderResearchInfo() -> Bool {
        guard let value = userDefaults.object(forKey: "hasSentFolderResearchInfo") else {
            return false
        }
        return Bool(value as! Bool)
    }

    func hasSeenReactionsWhatsNewScreen() -> Bool {
        guard let value = userDefaults.object(forKey: "hasSeenReactionsWhatsNewScreen") else {
            return false
        }
        return Bool(value as! Bool)
    }

    func hasSeenControlWhatsNewScreen() -> Bool {
        guard let value = userDefaults.object(forKey: "hasSeenControlWhatsNewScreen") else {
            return false
        }
        return Bool(value as! Bool)
    }

    func getHasSeenRecurringDonationBanner() -> Bool {
        guard let value = userDefaults.object(forKey: "hasSeenRecurringDonationBanner") else {
            return false
        }
        return Bool(value as! Bool)
    }

    func getHasSeenBetaBanner() -> Bool {
        guard let value = userDefaults.object(forKey: "hasSeenBetaBanner") else {
            return false
        }
        return Bool(value as! Bool)
    }

    func getHasSeenBetaSurveyBanner() -> Bool {
        guard let value = userDefaults.object(forKey: "hasSeenBetaSurveyBanner") else {
            return false
        }
        return Bool(value as! Bool)
    }

    func getShareManyMessageShowCount() -> Int {
        guard let value = userDefaults.object(forKey: "shareManyMessageShowCount") else {
            return 0
        }
        return Int(value as! Int)
    }

    func getLastUpdateAttempt() -> String {
        guard let value = userDefaults.object(forKey: "lastUpdateAttempt") else {
            return ""
        }
        return String(value as! String)
    }

    func hasDismissedRetro2024Banner() -> Bool {
        guard let value = userDefaults.object(forKey: "hasDismissedRetro2024Banner") else {
            return false
        }
        return Bool(value as! Bool)
    }

    func getHasSeenFirstUpdateIncentiveBanner() -> Bool {
        guard let value = userDefaults.object(forKey: "hasSeenFirstUpdateIncentiveBanner") else {
            return false
        }
        return Bool(value as! Bool)
    }

    func getHasSentFirstUpdateIncentiveMetric() -> Bool {
        guard let value = userDefaults.object(forKey: "hasSentFirstUpdateIncentiveMetric") else {
            return false
        }
        return Bool(value as! Bool)
    }

    func hasSeenNewTrendsUpdateWayBanner() -> Bool {
        guard let value = userDefaults.object(forKey: "hasSeenNewTrendsUpdateWayBanner") else {
            return false
        }
        return Bool(value as! Bool)
    }

    func folderResearchHashes() -> [String: String]? {
        guard let value = userDefaults.object(forKey: "folderResearchHash") else {
            return nil
        }
        return value as? [String: String]
    }

    func lastFolderResearchSyncDateTime() -> Date? {
        guard let value = userDefaults.object(forKey: "lastFolderResearchSyncDateTime") else {
            return nil
        }
        return Date(timeIntervalSince1970: value as! Double)
    }

    func hasSeenPinReactionsBanner() -> Bool {
        guard let value = userDefaults.object(forKey: "hasSeenPinReactionsBanner") else {
            return false
        }
        return Bool(value as! Bool)
    }
}

// MARK: - Setters

extension AppPersistentMemory {

    func setHasSentDeviceModelToServer(to newValue: Bool) {
        userDefaults.set(newValue, forKey: "hasSentDeviceModelToServer")
    }
    
    func setLastSendDateOfUserPersonalTrendsToServer(to newValue: Date) {
        userDefaults.set(newValue.timeIntervalSince1970, forKey: "lastSendDateOfUserPersonalTrendsToServer")
    }
    
    func setFolderBannerWasDismissed(to newValue: Bool) {
        userDefaults.set(newValue, forKey: "folderBannerWasDismissed")
    }
    
    func setShouldRetrySendingDevicePushToken(to newValue: Bool) {
        userDefaults.set(newValue, forKey: "shouldRetrySendingDevicePushToken")
    }
    
    func hasShownNotificationsOnboarding(_ newValue: Bool) {
        userDefaults.set(newValue, forKey: "hasShownNotificationsOnboarding")
    }
    
    func setHasHiddenShareAsVideoTextSocialNetworkTip(to newValue: Bool) {
        userDefaults.set(newValue, forKey: "hasHiddenShareAsVideoTwitterTip")
    }
    
    func setHasHiddenShareAsVideoInstagramTip(to newValue: Bool) {
        userDefaults.set(newValue, forKey: "hasHiddenShareAsVideoInstagramTip")
    }
    
    func setHasDismissedJoinFolderResearchBanner(to newValue: Bool) {
        userDefaults.set(newValue, forKey: "hasDismissedJoinFolderResearchBanner")
    }
    
    func setHasSentFolderResearchInfo(to newValue: Bool) {
        userDefaults.set(newValue, forKey: "hasSentFolderResearchInfo")
    }

    func hasSeenReactionsWhatsNewScreen(_ newValue: Bool) {
        userDefaults.set(newValue, forKey: "hasSeenReactionsWhatsNewScreen")
    }

    func hasSeenControlWhatsNewScreen(_ newValue: Bool) {
        userDefaults.set(newValue, forKey: "hasSeenControlWhatsNewScreen")
    }

    func setHasSeenRecurringDonationBanner(to newValue: Bool) {
        userDefaults.set(newValue, forKey: "hasSeenRecurringDonationBanner")
    }

    func setHasSeenBetaBanner(to newValue: Bool) {
        userDefaults.set(newValue, forKey: "hasSeenBetaBanner")
    }

    func setHasSeenBetaSurveyBanner(to newValue: Bool) {
        userDefaults.set(newValue, forKey: "hasSeenBetaSurveyBanner")
    }

    func increaseShareManyMessageShowCountByOne() {
        let currentCount = getShareManyMessageShowCount()
        userDefaults.set(currentCount + 1, forKey: "shareManyMessageShowCount")
    }

    func setLastUpdateAttempt(to newValue: String) {
        userDefaults.set(newValue, forKey: "lastUpdateAttempt")
    }

    func dismissedRetro2024Banner(_ newValue: Bool) {
        userDefaults.set(newValue, forKey: "hasDismissedRetro2024Banner")
    }

    func setHasSeenFirstUpdateIncentiveBanner(to newValue: Bool) {
        userDefaults.set(newValue, forKey: "hasSeenFirstUpdateIncentiveBanner")
    }

    func setHasSentFirstUpdateIncentiveMetric(to newValue: Bool) {
        userDefaults.set(newValue, forKey: "hasSentFirstUpdateIncentiveMetric")
    }

    func setHasSeenNewTrendsUpdateWayBanner(to newValue: Bool) {
        userDefaults.set(newValue, forKey: "hasSeenNewTrendsUpdateWayBanner")
    }

    func folderResearchHashes(_ foldersHashes: [String: String]) {
        userDefaults.set(foldersHashes, forKey: "folderResearchHash")
    }

    func lastFolderResearchSyncDateTime(_ dateTime: Date) {
        userDefaults.set(dateTime.timeIntervalSince1970, forKey: "lastFolderResearchSyncDateTime")
    }

    func setHasSeenPinReactionsBanner(to newValue: Bool) {
        userDefaults.set(newValue, forKey: "hasSeenPinReactionsBanner")
    }
}
