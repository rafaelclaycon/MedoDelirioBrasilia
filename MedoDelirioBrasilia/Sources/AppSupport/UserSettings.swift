import Foundation

class UserSettings {

    // MARK: - Getters
    
    static func getShowOffensiveSounds() -> Bool {
        let userDefaults = UserDefaults.standard
        guard let value = userDefaults.object(forKey: "skipGetLinkInstructions") else {
            return false
        }
        return Bool(value as! Bool)
    }
    
    static func getSoundSortOption() -> Int {
        let userDefaults = UserDefaults.standard
        guard let value = userDefaults.object(forKey: "soundSortOption") else {
            return 2
        }
        return Int(value as! Int)
    }
    
    static func getEnableTrends() -> Bool {
        let userDefaults = UserDefaults.standard
        guard let value = userDefaults.object(forKey: "enableTrends") else {
            return true
        }
        return Bool(value as! Bool)
    }
    
    static func getEnableMostSharedSoundsByTheUser() -> Bool {
        let userDefaults = UserDefaults.standard
        guard let value = userDefaults.object(forKey: "enableMostSharedSoundsByTheUser") else {
            return true
        }
        return Bool(value as! Bool)
    }
    
    static func getEnableDayOfTheWeekTheUserSharesTheMost() -> Bool {
        let userDefaults = UserDefaults.standard
        guard let value = userDefaults.object(forKey: "enableDayOfTheWeekTheUserSharesTheMost") else {
            return true
        }
        return Bool(value as! Bool)
    }
    
    static func getEnableSoundsMostSharedByTheAudience() -> Bool {
        let userDefaults = UserDefaults.standard
        guard let value = userDefaults.object(forKey: "enableSoundsMostSharedByTheAudience") else {
            return true
        }
        return Bool(value as! Bool)
    }
    
    static func getEnableAppsThroughWhichTheUserSharesTheMost() -> Bool {
        let userDefaults = UserDefaults.standard
        guard let value = userDefaults.object(forKey: "enableAppsThroughWhichTheUserSharesTheMost") else {
            return true
        }
        return Bool(value as! Bool)
    }
    
    static func getEnableShareUserPersonalTrends() -> Bool {
        let userDefaults = UserDefaults.standard
        guard let value = userDefaults.object(forKey: "enableShareUserPersonalTrends") else {
            return true
        }
        return Bool(value as! Bool)
    }
    
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
    
    static func getHotWeatherBannerWasDismissed() -> Bool {
        let userDefaults = UserDefaults.standard
        guard let value = userDefaults.object(forKey: "hotWeatherBannerWasDismissed") else {
            return false
        }
        return Bool(value as! Bool)
    }
    
    // MARK: - Setters
    
    static func setShowOffensiveSounds(to newValue: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(newValue, forKey: "skipGetLinkInstructions")
    }
    
    static func setSoundSortOption(to newValue: Int) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(newValue, forKey: "soundSortOption")
    }
    
    static func setEnableTrends(to newValue: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(newValue, forKey: "enableTrends")
    }
    
    static func setEnableMostSharedSoundsByTheUser(to newValue: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(newValue, forKey: "enableMostSharedSoundsByTheUser")
    }
    
    static func setEnableDayOfTheWeekTheUserSharesTheMost(to newValue: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(newValue, forKey: "enableDayOfTheWeekTheUserSharesTheMost")
    }
    
    static func setEnableSoundsMostSharedByTheAudience(to newValue: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(newValue, forKey: "enableSoundsMostSharedByTheAudience")
    }
    
    static func setEnableAppsThroughWhichTheUserSharesTheMost(to newValue: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(newValue, forKey: "enableAppsThroughWhichTheUserSharesTheMost")
    }
    
    static func setEnableShareUserPersonalTrends(to newValue: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(newValue, forKey: "enableShareUserPersonalTrends")
    }
    
    static func setHasSentDeviceModelToServer(to newValue: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(newValue, forKey: "hasSentDeviceModelToServer")
    }
    
    static func setLastSendDateOfUserPersonalTrendsToServer(to newValue: Date) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(newValue.timeIntervalSince1970, forKey: "lastSendDateOfUserPersonalTrendsToServer")
    }
    
    static func setHotWeatherBannerWasDismissed(to newValue: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(newValue, forKey: "hotWeatherBannerWasDismissed")
    }

}
