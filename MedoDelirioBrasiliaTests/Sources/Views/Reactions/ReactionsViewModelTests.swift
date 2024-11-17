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

    override func tearDownWithError() throws {
        sut = nil
        reactionRepository = nil
    }

    @MainActor
    func test_whenNoPinnedReactions_shouldDisplayNothing() async throws {
        reactionRepository = FakeReactionRepository()
        sut = .init(reactionRepository: reactionRepository)

        await sut.onViewLoaded()

        if case .loaded(let reactionGroup) = sut.state {
            XCTAssertTrue(reactionGroup.pinned.isEmpty, "Pinned reactions should be empty.")
        } else {
            XCTFail("state should be .loaded.")
        }
    }
}
