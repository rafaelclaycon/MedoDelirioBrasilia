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
    
    // MARK: - Setters
    
    static func setShowOffensiveSounds(to newValue: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(newValue, forKey: "skipGetLinkInstructions")
    }

}
