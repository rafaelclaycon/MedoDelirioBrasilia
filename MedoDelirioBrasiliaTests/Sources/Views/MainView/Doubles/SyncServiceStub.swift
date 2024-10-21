//
//  SyncServiceStub.swift
//  MedoDelirioBrasiliaTests
//
//  Created by Rafael Schmitt on 08/07/23.
//

@testable import MedoDelirio
import Foundation

class SyncServiceStub: SyncServiceProtocol {

    var updates: [MedoDelirio.UpdateEvent] = []
    var hasConnectivityResult = true
    var timesProcessWasCalled: Int = 0
    var loseConectivityAfterUpdate: Int? = nil
    var errorToThrowOnUpdate: NetworkRabbitError? = nil

    func getUpdates(from updateDateToConsider: String) async throws -> [MedoDelirio.UpdateEvent] {
        if let errorToThrowOnUpdate = errorToThrowOnUpdate {
            throw errorToThrowOnUpdate
        }

        guard updateDateToConsider != "all" else { return updates }

        return updates.filter {
            return $0.dateTime > updateDateToConsider
        }
    }

//    func hasConnectivity() -> Bool {
//        if let loseConectivityCount = loseConectivityAfterUpdate, timesProcessWasCalled >= loseConectivityCount {
//            return false
//        }
//        return hasConnectivityResult
//    }

    func process(updateEvent: MedoDelirio.UpdateEvent) async {
        timesProcessWasCalled += 1
        return
    }
}
