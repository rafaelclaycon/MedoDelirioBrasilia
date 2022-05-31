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
            return 0
        }
        return Int(value as! Int)
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

}
