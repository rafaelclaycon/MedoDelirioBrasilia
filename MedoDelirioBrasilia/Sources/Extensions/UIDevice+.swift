import UIKit

// MARK: - Physical Characteristics

extension UIDevice {

    /// Same width in points as 4-inch iPhones used to have.
    /// Now applies to Display Zoom == Larger Text for 16 Pro and down.
    static var isNarrowestWidth: Bool {
        guard UIDevice.isiPhone else {
            return false
        }
        return UIScreen.main.bounds.width == 320
    }

    /// In default non-Display Zoom mode, this applies to SE 2, SE 3, XS, 11 Pro, 12 mini, 13 mini.
    static var isSmallDevice: Bool {
        guard UIDevice.isiPhone else {
            return false
        }
        return UIScreen.main.bounds.width < 380
    }

    static var isControlCenterAccessibleFromTheTop: Bool {
        guard !isiPad else { return true }
        return !modelName.contains("SE")
    }
}

// MARK: - Software Characteristics

extension UIDevice {

    static func supportsiOSiPadOS18(
        isMac: Bool = UIDevice.isMac,
        isiPad: Bool = UIDevice.isiPad,
        _ modelName: String = UIDevice.modelName
    ) -> Bool {
        guard !isMac else { return false }
        guard !isiPad else {
            return ![
                "iPad (6th generation)",
                "iPad Pro (10.5-inch)",
                "iPad Pro (12.9-inch) (2nd generation)"
            ].contains(modelName)
        }
        return true
    }

    static var isRunningSoftwareVersion26: Bool {
        let version = UIDevice.current.systemVersion
        return version.contains("19") || version.contains("26")
    }

    static var systemMarketingName: String {
        if self.isMac {
            return "macOS"
        } else if UIDevice.isiPhone {
            return "iOS"
        } else {
            return "iPadOS"
        }
    }
}

// MARK: - Is specific device

extension UIDevice {
    
    static var isiPadMini: Bool {
        let model = UIDevice.modelName
        return model.contains("iPad mini")
    }

    static var isiPhone: Bool {
        self.current.userInterfaceIdiom == .phone
    }

    static var isiPad: Bool {
        self.current.userInterfaceIdiom == .pad
    }

    static var isMac: Bool {
        ProcessInfo.processInfo.isiOSAppOnMac
    }

    static var deviceGenericName: String {
        if UIDevice.isiPhone {
            return "iPhone"
        } else if UIDevice.isiPad {
            return "iPad"
        } else {
            return "Mac"
        }
    }
}

// MARK: - Device Info

public extension UIDevice {

    static let modelName: String = {
        if ProcessInfo.processInfo.isiOSAppOnMac || ProcessInfo.processInfo.isMacCatalystApp {
            return "Mac"
        }
        
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPhone11,8":                                     return "iPhone XR" // 2018 - A12 (4E,2P) - 3 GB
            case "iPhone11,2":                                     return "iPhone XS" // 2018 - A12 (4E,2P) - 4 GB
            case "iPhone11,4", "iPhone11,6":                       return "iPhone XS Max" // 2018 - A12 (4E,2P) - 4 GB
            case "iPhone12,1":                                     return "iPhone 11" // 2019 - A13 - 4 GB
            case "iPhone12,3":                                     return "iPhone 11 Pro" // 2019 - A13 - 4 GB
            case "iPhone12,5":                                     return "iPhone 11 Pro Max" // 2019 - A13 - 4 GB
            case "iPhone12,8":                                     return "iPhone SE (2nd generation)" // 2020 - A13 - 3 GB
            case "iPhone13,1":                                     return "iPhone 12 mini" // 2020 - A14 - 4 GB
            case "iPhone13,2":                                     return "iPhone 12" // 2020 - A14 - 4 GB
            case "iPhone13,3":                                     return "iPhone 12 Pro" // 2020 - A14 - 6 GB
            case "iPhone13,4":                                     return "iPhone 12 Pro Max" // 2020 - A14 - 6 GB
            case "iPhone14,4":                                     return "iPhone 13 mini" // 2021 - A15
            case "iPhone14,5":                                     return "iPhone 13" // 2021 - A15
            case "iPhone14,2":                                     return "iPhone 13 Pro" // 2021 - A15
            case "iPhone14,3":                                     return "iPhone 13 Pro Max" // 2021 - A15
            case "iPhone14,6":                                     return "iPhone SE (3rd generation)" // 2022 - A15
            case "iPhone14,7":                                     return "iPhone 14" // 2022 - A15
            case "iPhone14,8":                                     return "iPhone 14 Plus" // 2022 - A15
            case "iPhone15,2":                                     return "iPhone 14 Pro" // 2022 - A16
            case "iPhone15,3":                                     return "iPhone 14 Pro Max" // 2022 - A16
            case "iPhone15,4":                                     return "iPhone 15" // 2023 - A16
            case "iPhone15,5":                                     return "iPhone 15 Plus" // 2023 - A16
            case "iPhone16,1":                                     return "iPhone 15 Pro" // 2023 - A17 Pro (4E,2P) - 8 GB
            case "iPhone16,2":                                     return "iPhone 15 Pro Max" // 2023 - A17 Pro
            case "iPhone17,3":                                     return "iPhone 16" // 2024 - A18
            case "iPhone17,4":                                     return "iPhone 16 Plus" // 2024 - A18
            case "iPhone17,1":                                     return "iPhone 16 Pro" // 2024 - A18 Pro - 8 GB
            case "iPhone17,2":                                     return "iPhone 16 Pro Max" // 2024 - A18 Pro - 8 GB
            case "iPhone17,5":                                     return "iPhone 16e" // 2025 - A18 (4E,2P) - 8 GB

            case "iPad7,5", "iPad7,6":                             return "iPad (6th generation)" // 2018 - A10 (2E,2P) - 2 GB
            case "iPad7,11", "iPad7,12":                           return "iPad (7th generation)" // 2019 - A10 - 3 GB
            case "iPad11,6", "iPad11,7":                           return "iPad (8th generation)" // 2020 - A12 - 3 GB
            case "iPad12,1", "iPad12,2":                           return "iPad (9th generation)" // 2021 - A13 - 3 GB
            case "iPad13,18", "iPad13,19":                         return "iPad (10th generation)" // 2022 - A14 (4E,2P) - 4 GB
            case "iPad15,7":                                       return "iPad (A16)" // 2025 - A16 (3E,2P) - 6 GB

            case "iPad11,3", "iPad11,4":                           return "iPad Air (3rd generation)" // 2019 - A12 (4E, 2P) - 3 GB
            case "iPad13,1", "iPad13,2":                           return "iPad Air (4th generation)" // 2020 - A14 (4E, 2P) - 4 GB
            case "iPad13,16", "iPad13,17":                         return "iPad Air (5th generation)" // 2022 - M1 - 8 GB
            case "iPad14,8":                                       return "iPad Air 11-inch (M2)" // 2024 - M2 - 8 GB
            case "iPad14,10":                                      return "iPad Air 13-inch (M2)" // 2024 - M2 - 8 GB
            case "iPad15,3":                                       return "iPad Air 11-inch (M3)" // 2025 - M3 - 8 GB
            case "iPad15,5":                                       return "iPad Air 13-inch (M3)" // 2025 - M3 - 8 GB

            case "iPad11,1", "iPad11,2":                           return "iPad mini (5th generation)" // 2019 - A12 - 3 GB
            case "iPad14,1", "iPad14,2":                           return "iPad mini (6th generation)" // 2021 - A15 - 4 GB
            case "iPad16,2":                                       return "iPad mini (A17 Pro)" // 2024 - A17 Pro - 8 GB

            case "iPad7,3", "iPad7,4":                             return "iPad Pro (10.5-inch)" // 2017 - A10X (3E,3P) - 4 GB
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":       return "iPad Pro (11-inch) (1st generation)" // 2018 - A12X - 4 or 6 GB
            case "iPad8,9", "iPad8,10":                            return "iPad Pro (11-inch) (2nd generation)" // 2020 - A12Z - 6 GB
            case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7":   return "iPad Pro (11-inch) (3rd generation)" // 2021 - M1 - 8 or 16 GB
            case "iPad14,3", "iPad14,4":                           return "iPad Pro (11-inch) (4th generation)" // 2022 - M2 - 8 or 16 GB
            case "iPad7,1", "iPad7,2":                             return "iPad Pro (12.9-inch) (2nd generation)" // 2017 - A10X - 4 GB
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":       return "iPad Pro (12.9-inch) (3rd generation)" // 2018 - A12X - 4 or 6 GB
            case "iPad8,11", "iPad8,12":                           return "iPad Pro (12.9-inch) (4th generation)" // 2020 - A12Z - 6 GB
            case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11": return "iPad Pro (12.9-inch) (5th generation)" // 2021 - M1 - 8 or 16 GB
            case "iPad14,5", "iPad14,6":                           return "iPad Pro (12.9-inch) (6th generation)" // 2022 - M2 - 8 or 16 GB
            case "iPad16,4":                                       return "iPad Pro 11-inch (M4)" // 2024 - M4 (6E,3-4P) - 8 or 16 GB
            case "iPad16,6":                                       return "iPad Pro 13-inch (M4)" // 2024 - M4 (6E,3-4P) - 8 or 16 GB

            case "RealityDevice14,1":                              return "Apple Vision Pro" // 2024 - M2 (4E,4P) - 16 GB

            case "i386", "x86_64", "arm64":                        return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                              return identifier
            }
            #endif
        }
        
        return mapToDevice(identifier: identifier)
    }()
}
