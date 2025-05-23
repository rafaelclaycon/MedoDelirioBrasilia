//
//  FakeAnalyticsService.swift
//  MedoDelirioBrasiliaTests
//
//  Created by Rafael Schmitt on 16/04/25.
//

import Foundation
@testable import MedoDelirio

final class FakeAnalyticsService: AnalyticsServiceProtocol {

    var didCallSendOriginatingScreen = false
    var didCallSendCurrentScreen = false

    func send(originatingScreen: String, action: String) async {
        didCallSendOriginatingScreen = true
    }

    func send(currentScreen: String, folderName: String, action: String) async {
        didCallSendCurrentScreen = true
    }
}
