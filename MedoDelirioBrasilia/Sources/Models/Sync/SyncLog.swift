//
//  SyncLog.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 24/05/23.
//

import UIKit

struct SyncLog: Hashable, Codable, Identifiable {

    let id: String
    let logType: SyncLogType
    let description: String
    let dateTime: String
    var installId: String
    var systemName: String
    var systemVersion: String
    var isiOSAppOnMac: Bool
    var appVersion: String
    var currentTimeZone: String
    let updateEventId: String

    init(
        logType: SyncLogType,
        description: String,
        updateEventId: String
    ) {
        self.id = UUID().uuidString
        self.logType = logType
        self.description = description
        self.dateTime = Date.now.iso8601withFractionalSeconds
        self.installId = UIDevice.customInstallId
        self.systemName = UIDevice.current.systemName
        self.systemVersion = UIDevice.current.systemVersion
        self.isiOSAppOnMac = ProcessInfo.processInfo.isiOSAppOnMac
        self.appVersion = Versioneer.appVersion
        self.currentTimeZone = TimeZone.current.abbreviation() ?? .empty
        self.updateEventId = updateEventId
    }

    init(
        id: String,
        logType: SyncLogType,
        description: String,
        dateTime: String,
        updateEventId: String
    ) {
        self.id = id
        self.logType = logType
        self.description = description
        self.dateTime = dateTime
        self.installId = UIDevice.customInstallId
        self.systemName = UIDevice.current.systemName
        self.systemVersion = ""
        self.isiOSAppOnMac = ProcessInfo.processInfo.isiOSAppOnMac
        self.appVersion = ""
        self.currentTimeZone = ""
        self.updateEventId = updateEventId
    }
}

enum SyncLogType: String, Codable {

    case success, error
}
