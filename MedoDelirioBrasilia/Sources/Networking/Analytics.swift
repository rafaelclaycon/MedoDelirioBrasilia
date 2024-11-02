//
//  Analytics.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 26/11/23.
//

import UIKit

protocol AnalyticsProtocol {

    func send(originatingScreen: String, action: String)
}

final class Analytics: AnalyticsProtocol {

    private let apiClient: NetworkRabbit

    // MARK: - Initializer

    init(
        apiClient: NetworkRabbit = NetworkRabbit(serverPath: APIConfig.apiURL)
    ) {
        self.apiClient = apiClient
    }

    func send(
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
        apiClient.post(usageMetric: usageMetric)
    }

    func sendUsageMetricToServer(
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
        apiClient.post(usageMetric: usageMetric)
    }
}
