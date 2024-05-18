//
//  AppPersistentMemory.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 17/08/22.
//

import Foundation

/// Different from User Settings, App Memory are settings that help the app remember stuff to avoid asking again or doing a network job more than once per day.
class AppPersistentMemory {

    // MARK: - Getters
    
    static func getHasSentDeviceModelToServer() -> Bool {
        let userDefaults = UserDefaults.standard
        guard let value = userDefaults.object(forKey: "hasSentDeviceModelToServer") else {
            return false
        }
        return Bool(value as! Bool)
    }
    
    static func getLastSendDateOfUserPersonalTrendsToServer() -> Date? {
        let userDefaults = UserDefaults.standard
        guard let value = userDefaults.object(forKey: "lastSendDateOfUserPersonalTrendsToServer") else {
            return nil
        }
        return Date(timeIntervalSince1970: value as! Double)
    }
    
    static func getFolderBannerWasDismissed() -> Bool {
        let userDefaults = UserDefaults.standard
        guard let value = userDefaults.object(forKey: "folderBannerWasDismissed") else {
            return false
        }
        return Bool(value as! Bool)
    }
    
    static func getShouldRetrySendingDevicePushToken() -> Bool {
        let userDefaults = UserDefaults.standard
        guard let value = userDefaults.object(forKey: "shouldRetrySendingDevicePushToken") else {
            return true
        }
        return Bool(value as! Bool)
    }
    
    static func hasShownNotificationsOnboarding() -> Bool {
        let userDefaults = UserDefaults.standard
        guard let value = userDefaults.object(forKey: "hasShownNotificationsOnboarding") else {
            return false
        }
        return Bool(value as! Bool)
    }
    
    static func getHasHiddenShareAsVideoTextSocialNetworkTip() -> Bool {
        let userDefaults = UserDefaults.standard
        guard let value = userDefaults.object(forKey: "hasHiddenShareAsVideoTwitterTip") else {
            return false
        }
        return Bool(value as! Bool)
    }
    
    static func getHasHiddenShareAsVideoInstagramTip() -> Bool {
        let userDefaults = UserDefaults.standard
        guard let value = userDefaults.object(forKey: "hasHiddenShareAsVideoInstagramTip") else {
            return false
        }
        return Bool(value as! Bool)
    }
    
    static func getHasDismissedJoinFolderResearchBanner() -> Bool? {
        let userDefaults = UserDefaults.standard
        guard let value = userDefaults.object(forKey: "hasDismissedJoinFolderResearchBanner") else {
            return nil
        }
        return Bool(value as! Bool)
    }
    
    static func getHasJoinedFolderResearch() -> Bool {
        let userDefaults = UserDefaults.standard
        guard let value = userDefaults.object(forKey: "hasJoinedFolderResearch") else {
            return false
        }
        return Bool(value as! Bool)
    }
    
    static func getHasSentFolderResearchInfo() -> Bool {
        let userDefaults = UserDefaults.standard
        guard let value = userDefaults.object(forKey: "hasSentFolderResearchInfo") else {
            return false
        }
        return Bool(value as! Bool)
    }

    static func hasSeenReactionsWhatsNewScreen() -> Bool {
        let userDefaults = UserDefaults.standard
        guard let value = userDefaults.object(forKey: "hasSeenReactionsWhatsNewScreen-A") else {
            return false
        }
        return Bool(value as! Bool)
    }

    static func getHasSeenRecurringDonationBanner() -> Bool {
        let userDefaults = UserDefaults.standard
        guard let value = userDefaults.object(forKey: "hasSeenRecurringDonationBanner") else {
            return false
        }
        return Bool(value as! Bool)
    }

    static func getHasSeenBetaBanner() -> Bool {
        let userDefaults = UserDefaults.standard
        guard let value = userDefaults.object(forKey: "hasSeenBetaBanner") else {
            return false
        }
        return Bool(value as! Bool)
    }

    static func getHasSeenBetaSurveyBanner() -> Bool {
        let userDefaults = UserDefaults.standard
        guard let value = userDefaults.object(forKey: "hasSeenBetaSurveyBanner") else {
            return false
        }
        return Bool(value as! Bool)
    }

    static func getShareManyMessageShowCount() -> Int {
        let userDefaults = UserDefaults.standard
        guard let value = userDefaults.object(forKey: "shareManyMessageShowCount") else {
            return 0
        }
        return Int(value as! Int)
    }

    static func getLastUpdateAttempt() -> String {
        let userDefaults = UserDefaults.standard
        guard let value = userDefaults.object(forKey: "lastUpdateAttempt") else {
            return ""
        }
        return String(value as! String)
    }

    static func getHasSeenRetroBanner() -> Bool {
        let userDefaults = UserDefaults.standard
        guard let value = userDefaults.object(forKey: "hasSeenRetroBanner") else {
            return false
        }
        return Bool(value as! Bool)
    }

    static func getHasSeenFirstUpdateIncentiveBanner() -> Bool {
        let userDefaults = UserDefaults.standard
        guard let value = userDefaults.object(forKey: "hasSeenFirstUpdateIncentiveBanner") else {
            return false
        }
        return Bool(value as! Bool)
    }

    static func getHasSentFirstUpdateIncentiveMetric() -> Bool {
        let userDefaults = UserDefaults.standard
        guard let value = userDefaults.object(forKey: "hasSentFirstUpdateIncentiveMetric") else {
            return false
        }
        return Bool(value as! Bool)
    }

    static func hasSeenNewTrendsUpdateWayBanner() -> Bool {
        let userDefaults = UserDefaults.standard
        guard let value = userDefaults.object(forKey: "hasSeenNewTrendsUpdateWayBanner") else {
            return false
        }
        return Bool(value as! Bool)
    }

    // MARK: - Setters
    
    static func setHasSentDeviceModelToServer(to newValue: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(newValue, forKey: "hasSentDeviceModelToServer")
    }
    
    static func setLastSendDateOfUserPersonalTrendsToServer(to newValue: Date) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(newValue.timeIntervalSince1970, forKey: "lastSendDateOfUserPersonalTrendsToServer")
    }
    
    static func setFolderBannerWasDismissed(to newValue: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(newValue, forKey: "folderBannerWasDismissed")
    }
    
    static func setShouldRetrySendingDevicePushToken(to newValue: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(newValue, forKey: "shouldRetrySendingDevicePushToken")
    }
    
    static func hasShownNotificationsOnboarding(_ newValue: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(newValue, forKey: "hasShownNotificationsOnboarding")
    }
    
    static func setHasHiddenShareAsVideoTextSocialNetworkTip(to newValue: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(newValue, forKey: "hasHiddenShareAsVideoTwitterTip")
    }
    
    static func setHasHiddenShareAsVideoInstagramTip(to newValue: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(newValue, forKey: "hasHiddenShareAsVideoInstagramTip")
    }
    
    static func setHasDismissedJoinFolderResearchBanner(to newValue: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(newValue, forKey: "hasDismissedJoinFolderResearchBanner")
    }
    
    static func setHasJoinedFolderResearch(to newValue: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(newValue, forKey: "hasJoinedFolderResearch")
    }
    
    static func setHasSentFolderResearchInfo(to newValue: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(newValue, forKey: "hasSentFolderResearchInfo")
    }

    static func hasSeenReactionsWhatsNewScreen(_ newValue: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(newValue, forKey: "hasSeenReactionsWhatsNewScreen-A")
    }

    static func setHasSeenRecurringDonationBanner(to newValue: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(newValue, forKey: "hasSeenRecurringDonationBanner")
    }

    static func setHasSeenBetaBanner(to newValue: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(newValue, forKey: "hasSeenBetaBanner")
    }

    static func setHasSeenBetaSurveyBanner(to newValue: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(newValue, forKey: "hasSeenBetaSurveyBanner")
    }

    static func increaseShareManyMessageShowCountByOne() {
        let currentCount = AppPersistentMemory.getShareManyMessageShowCount()
        let userDefaults = UserDefaults.standard
        userDefaults.set(currentCount + 1, forKey: "shareManyMessageShowCount")
    }

    static func setLastUpdateAttempt(to newValue: String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(newValue, forKey: "lastUpdateAttempt")
    }

    static func setHasSeenRetroBanner(to newValue: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(newValue, forKey: "hasSeenRetroBanner")
    }

    static func setHasSeenFirstUpdateIncentiveBanner(to newValue: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(newValue, forKey: "hasSeenFirstUpdateIncentiveBanner")
    }

    static func setHasSentFirstUpdateIncentiveMetric(to newValue: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(newValue, forKey: "hasSentFirstUpdateIncentiveMetric")
    }

    static func setHasSeenNewTrendsUpdateWayBanner(to newValue: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(newValue, forKey: "hasSeenNewTrendsUpdateWayBanner")
    }
}
