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

    func updateError(_ description: String, updateEventId: String) {
        errorHistory[description] = updateEventId
    }

    func updateError(_ description: String) {
        errorHistory[description] = ""
    }

    func updateSuccess(_ description: String, updateEventId: String) {
        successHistory[description] = updateEventId
    }

    func updateSuccess(_ description: String) {
        successHistory[description] = ""
    }
}
