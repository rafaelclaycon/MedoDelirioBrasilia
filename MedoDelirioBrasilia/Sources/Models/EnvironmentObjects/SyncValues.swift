//
//  SyncValues.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 20/08/23.
//

import Foundation

@Observable
class SyncValues {

    var syncStatus: SyncUIStatus

    init(
        syncStatus: SyncUIStatus = .updating
    ) {
        self.syncStatus = syncStatus
    }
}
