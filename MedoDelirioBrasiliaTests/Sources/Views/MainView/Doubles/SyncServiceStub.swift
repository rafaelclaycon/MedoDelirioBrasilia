//
//  SyncServiceStub.swift
//  MedoDelirioBrasiliaTests
//
//  Created by Rafael Schmitt on 08/07/23.
//

@testable import MedoDelirio
import Foundation

class SyncServiceStub: SyncServiceProtocol {

    var predefinedUpdates: [MedoDelirio.UpdateEvent] = []
    var hasConnectivityResult = true

    func getUpdates(from updateDateToConsider: String) async throws -> [MedoDelirio.UpdateEvent] {
        return predefinedUpdates
    }

    func hasConnectivity() -> Bool {
        return hasConnectivityResult
    }

    func process(updateEvent: MedoDelirio.UpdateEvent) async {
        return
    }
}
