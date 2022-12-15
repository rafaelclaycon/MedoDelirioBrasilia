//
//  UsageMetric.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 11/12/22.
//

import Foundation

struct UsageMetric: Hashable, Codable {

    var customInstallId: String
    var originatingScreen: String
    var destinationScreen: String
    var systemName: String
    var isiOSAppOnMac: Bool
    var appVersion: String
    var dateTime: String
    var currentTimeZone: String
    
    init(customInstallId: String,
         originatingScreen: String,
         destinationScreen: String,
         systemName: String,
         isiOSAppOnMac: Bool,
         appVersion: String,
         dateTime: String,
         currentTimeZone: String) {
        self.customInstallId = customInstallId
        self.originatingScreen = originatingScreen
        self.destinationScreen = destinationScreen
        self.systemName = systemName
        self.isiOSAppOnMac = isiOSAppOnMac
        self.appVersion = appVersion
        self.dateTime = dateTime
        self.currentTimeZone = currentTimeZone
    }

}
