//
//  FakeLoggerService.swift
//  MedoDelirioBrasiliaTests
//
//  Created by Rafael Schmitt on 23/07/23.
//

@testable import MedoDelirio
import Foundation

class FakeLoggerService: LoggerProtocol {

    var errorHistory: [String: String] = [:]
    var successHistory: [String: String] = [:]

    func logShared(
        _ type: ContentType,
        contentId: String,
        destination: ShareDestination,
        destinationBundleId: String
    ) {}

    func logSyncError(description: String, updateEventId: String) {
        errorHistory[description] = updateEventId
    }

    func logSyncError(description: String) {
        errorHistory[description] = ""
    }

    func logSyncSuccess(description: String, updateEventId: String) {
        successHistory[description] = updateEventId
    }

    func logSyncSuccess(description: String) {
        successHistory[description] = ""
    }
}
