//
//  AppPersistentMemory.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 17/08/22.
//

import Foundation

protocol AppPersistentMemoryProtocol {

    func folderResearchHash() -> String?
    func folderResearchHash(_ hash: String)

    func getHasSentFolderResearchInfo() -> Bool
    func setHasSentFolderResearchInfo(to newValue: Bool)
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

    func getHasSeenRetroBanner() -> Bool {
        guard let value = userDefaults.object(forKey: "hasSeenRetroBanner") else {
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

    func folderResearchHash() -> String? {
        guard let value = userDefaults.object(forKey: "folderResearchHash") else {
            return nil
        }
        return String(value as! String)
    }

    // MARK: - Setters
    
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

    func setHasSeenRetroBanner(to newValue: Bool) {
        userDefaults.set(newValue, forKey: "hasSeenRetroBanner")
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

    func folderResearchHash(_ hash: String) {
        userDefaults.set(hash, forKey: "folderResearchHash")
    }
}
