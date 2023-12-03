//
//  Analytics.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 26/11/23.
//

import UIKit

class Analytics {

    static func sendUsageMetricToServer(
        originatingScreen: String,
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
        networkRabbit.post(usageMetric: usageMetric)
    }
}
