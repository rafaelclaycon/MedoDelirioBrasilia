//
//  Analytics.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 26/11/23.
//

import UIKit

class Analytics {

    static func send(
        originatingScreen: String = "",
        action: String
    ) {
        let usageMetric = UsageMetric(
            customInstallId: UIDevice.customInstallId,
            originatingScreen: originatingScreen,
            destinationScreen: action,
            systemName: UIDevice.current.systemName,
            isiOSAppOnMac: ProcessInfo.processInfo.isiOSAppOnMac,
            appVersion: Versioneer.appVersion,
            dateTime: Date.now.iso8601withFractionalSeconds,
            currentTimeZone: TimeZone.current.abbreviation() ?? .empty
        )
        NetworkRabbit.shared.post(usageMetric: usageMetric)
    }

    static func sendUsageMetricToServer(
        folderName: String,
        action: String
    ) {
        let usageMetric = UsageMetric(
            customInstallId: UIDevice.customInstallId,
            originatingScreen: "FolderDetailView(\(folderName))",
            destinationScreen: action,
            systemName: UIDevice.current.systemName,
            isiOSAppOnMac: ProcessInfo.processInfo.isiOSAppOnMac,
            appVersion: Versioneer.appVersion,
            dateTime: Date.now.iso8601withFractionalSeconds,
            currentTimeZone: TimeZone.current.abbreviation() ?? .empty
        )
        NetworkRabbit.shared.post(usageMetric: usageMetric)
    }
}
