//
//  FakeContentUpdateService.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 24/05/25.
//

import Foundation

class FakeContentUpdateService: ContentUpdateServiceProtocol {

    var status: ContentUpdateStatus = .done
    var currentUpdate: Int = 0
    var totalUpdateCount: Int = 0


    public func update() async -> Bool {
        return false
    }
}
