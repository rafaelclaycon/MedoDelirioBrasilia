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

    init(
        syncStatus: SyncUIStatus = .updating
    ) {
        self.syncStatus = syncStatus
    }
}
