//
//  Logger.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 28/05/22.
//

import UIKit

internal protocol LoggerProtocol {

    func logShared(
        _ type: ContentType,
        contentId: String,
        destination: ShareDestination,
        destinationBundleId: String
    )

    func logSyncError(description: String, updateEventId: String)
    func logSyncError(description: String)

    func logSyncSuccess(description: String, updateEventId: String)
    func logSyncSuccess(description: String)
}

class Logger: LoggerProtocol {

    static let shared = Logger()

    // MARK: - Functions

    func logShared(
        _ type: ContentType,
        contentId: String,
        destination: ShareDestination,
        destinationBundleId: String
    ) {
        let shareLog = UserShareLog(
            installId: AppPersistentMemory().customInstallId,
            contentId: contentId,
            contentType: type.rawValue,
            dateTime: .now,
            destination: destination.rawValue,
            destinationBundleId: destinationBundleId,
            sentToServer: false
        )
        try? LocalDatabase.shared.insert(userShareLog: shareLog)
    }

    func shareCountStatsForServer() -> [ServerShareCountStat]? {
        guard 
            let items = try? LocalDatabase.shared.userShareStatsNotSentToServer(),
            items.count > 0
        else { return nil }
        return items
    }

    func uniqueBundleIdsForServer() -> [ServerShareBundleIdLog]? {
        guard
            let items = try? LocalDatabase.shared.getUniqueBundleIdsThatWereSharedTo(),
            items.count > 0
        else { return nil }
        return items
    }

    func logNetworkCall(
        callType: Int,
        requestUrl: String,
        requestBody: String?,
        response: String,
        wasSuccessful: Bool
    ) {
        let log = NetworkCallLog(
            callType: callType,
            requestBody: requestBody ?? .empty,
            response: response,
            dateTime: Date(),
            wasSuccessful: wasSuccessful
        )
        try? LocalDatabase.shared.insert(networkCallLog: log)
    }

    func logSyncError(
        description: String,
        updateEventId: String
    ) {
        let syncLog = SyncLog(
            logType: .error,
            description: description,
            updateEventId: updateEventId
        )
        LocalDatabase.shared.insert(syncLog: syncLog)
    }

    func logSyncError(
        description: String
    ) {
        let syncLog = SyncLog(
            logType: .error,
            description: description,
            updateEventId: ""
        )
        LocalDatabase.shared.insert(syncLog: syncLog)
    }

    func logSyncSuccess(
        description: String,
        updateEventId: String
    ) {
        let syncLog = SyncLog(
            logType: .success,
            description: description,
            updateEventId: updateEventId
        )
        LocalDatabase.shared.insert(syncLog: syncLog)
    }

    func logSyncSuccess(
        description: String
    ) {
        let syncLog = SyncLog(
            logType: .success,
            description: description,
            updateEventId: ""
        )
        LocalDatabase.shared.insert(syncLog: syncLog)
    }
}
