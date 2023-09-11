//
//  SyncValues.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 20/08/23.
//

import Foundation
import Combine

class SyncValues: ObservableObject {

    @Published var syncStatus: SyncUIStatus
    @Published var syncNow: Bool

    init(
        syncStatus: SyncUIStatus = .updating,
        syncNow: Bool = false
    ) {
        self.syncStatus = syncStatus
        self.syncNow = syncNow
    }
}
