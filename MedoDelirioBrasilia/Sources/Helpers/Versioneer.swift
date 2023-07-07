import Foundation

class Versioneer {

    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    static let buildVersionNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
}
