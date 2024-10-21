//
//  UpdateIncentive.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 26/11/23.
//

import UIKit

class UpdateIncentive {

    static let iPhonesThatSupportAbove15: [String] = [
        "iPhone 8", "iPhone 8 Plus",
        "iPhone X",
        "iPhone XS", "iPhone XS Max",
        "iPhone XR",
        "iPhone 11", "iPhone 11 Pro", "iPhone 11 Pro Max",
        "iPhone SE (2nd generation)",
        "iPhone 12", "iPhone 12 mini", "iPhone 12 Pro", "iPhone 12 Pro Max",
        "iPhone 13", "iPhone 13 mini", "iPhone 13 Pro", "iPhone 13 Pro Max",
        "iPhone SE (3rd generation)"
    ]

    static let iPhonesMaxSystemIs15: [String] = [
        "iPod touch (7th generation)",
        "iPhone 6s", "iPhone 6s Plus",
        "iPhone SE",
        "iPhone 7", "iPhone 7 Plus"
    ]

    static let iPhonesMaxSystemIs16: [String] = [
        "iPhone 8", "iPhone 8 Plus",
        "iPhone X"
    ]

    static let iPadsLimitedTo15: [String] = [
        "iPad mini 4", "iPad Air 2"
    ]

    static func shouldDisplayBanner(
        currentSystemVersion: String,
        deviceModel: String,
        isMac: Bool = UIDevice.isMac,
        isiPad: Bool = UIDevice.isiPad
    ) -> Bool {
        guard !isMac else { return false }
        guard currentSystemVersion.contains("15") else { return false }
        guard !isiPad else { return !iPadsLimitedTo15.contains(deviceModel.replacingOccurrences(of: "Simulator ", with: "")) }
        return iPhonesThatSupportAbove15.contains(deviceModel.replacingOccurrences(of: "Simulator ", with: ""))
    }

    static func maxSupportedVersion(
        deviceModel: String,
        isMac: Bool = UIDevice.isMac,
        isiPad: Bool = UIDevice.isiPad
    ) -> String? {
        guard !isMac else { return nil }
        guard !isiPad else { return "uma versão mais recente do iPadOS" }

        let normalizedModel = deviceModel.replacingOccurrences(of: "Simulator ", with: "")

        if iPhonesMaxSystemIs15.contains(normalizedModel) {
            return "iOS 15"
        } else if iPhonesMaxSystemIs16.contains(normalizedModel) {
            return "iOS 16"
        } else {
            return "iOS 17"
        }
    }
}
