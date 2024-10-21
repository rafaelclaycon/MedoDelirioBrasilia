//
//  SyncManagerDelegateSpy.swift
//  MedoDelirioBrasiliaTests
//
//  Created by Rafael Schmitt on 21/10/24.
//

import Foundation
@testable import MedoDelirio

class SyncManagerDelegateSpy: SyncManagerDelegate {

    var totalUpdateCountUpdates: [Int] = []
    var didProcessUpdateUpdates: [Int] = []
    var didFinishUpdatingUpdates: [(SyncUIStatus, Bool)] = []

    func set(totalUpdateCount: Int) {
        totalUpdateCountUpdates.append(totalUpdateCount)
    }

    func didProcessUpdate(number: Int) {
        didProcessUpdateUpdates.append(number)
    }

    func didFinishUpdating(status: SyncUIStatus, updateSoundList: Bool) {
        didFinishUpdatingUpdates.append((status, updateSoundList))
    }
}
