//
//  ReactionsViewModelTests.swift
//  MedoDelirioBrasiliaTests
//
//  Created by Rafael Schmitt on 17/11/24.
//

import XCTest
@testable import MedoDelirio

final class ReactionsViewModelTests: XCTestCase {

    private var sut: ReactionsView.ViewModel!

    private var reactionRepository: FakeReactionRepository!

    @MainActor
    override func setUpWithError() throws {
        reactionRepository = FakeReactionRepository()
        sut = .init(reactionRepository: reactionRepository)
    }

    override func tearDownWithError() throws {
        sut = nil
        reactionRepository = nil
    }

    func test_whenNoPinnedReactions_shouldDisplayNothing() throws {
        
    }
}
