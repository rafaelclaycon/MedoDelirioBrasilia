//
//  FakeContentUpdateService.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 24/05/25.
//

import Foundation

class FakeContentUpdateService: ContentUpdateServiceProtocol {

    var shouldReturnDidUpdate = false

    func update() async -> Bool {
        shouldReturnDidUpdate
    }
}
