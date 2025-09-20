//
//  FakeContentUpdateServiceDelegate.swift
//  MedoDelirioBrasiliaTests
//
//  Created by Rafael Schmitt on 21/10/24.
//

import Foundation
@testable import MedoDelirio

class FakeContentUpdateServiceDelegate: ContentUpdateServiceDelegate {

    var totalUpdateCountUpdates: [Int] = []
    var didProcessUpdateUpdates: [Int] = []
    var statusUpdates: [(ContentUpdateStatus, Bool)] = []

    func set(totalUpdateCount: Int) {
        totalUpdateCountUpdates.append(totalUpdateCount)
    }

    func didProcessUpdate(number: Int) {
        didProcessUpdateUpdates.append(number)
    }

    func update(status: ContentUpdateStatus, contentChanged: Bool) {
        statusUpdates.append((status, contentChanged))
    }
}
