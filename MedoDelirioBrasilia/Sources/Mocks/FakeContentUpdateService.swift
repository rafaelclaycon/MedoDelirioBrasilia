//
//  FakeContentUpdateService.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 24/05/25.
//

import Foundation

class FakeContentUpdateService: ContentUpdateServiceProtocol {

    var progressUpdates: AsyncThrowingStream<ProgressUpdate, Error> {
        AsyncThrowingStream { continuation in
            // Empty stream for testing
        }
    }
    
    var statusUpdates: AsyncThrowingStream<StatusUpdate, Error> {
        AsyncThrowingStream { continuation in
            // Empty stream for testing
        }
    }

    func update() async {
        // Empty implementation for testing
    }
}
