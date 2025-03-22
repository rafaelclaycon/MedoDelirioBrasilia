//
//  UpdateIncentiveTests.swift
//  MedoDelirioBrasiliaTests
//
//  Created by Rafael Schmitt on 26/11/23.
//

import XCTest
@testable import MedoDelirio

final class UpdateIncentiveTests: XCTestCase {

    func testMaxSupportedVersion_whenIsiPhone11_ShouldReturn17() throws {
        XCTAssertEqual(
            UpdateIncentive.maxSupportedVersion(deviceModel: "iPhone 11"),
            "iOS 17"
        )
    }

    func testMaxSupportedVersion_whenIsiPhoneSE3_ShouldReturn17() throws {
        XCTAssertEqual(
            UpdateIncentive.maxSupportedVersion(deviceModel: "iPhone SE (3rd generation)"),
            "iOS 17"
        )
    }

    func testMaxSupportedVersion_whenIsiPadAir2_ShouldReturnDefaultPhrase() throws {
        XCTAssertEqual(
            UpdateIncentive.maxSupportedVersion(deviceModel: "iPad Air (5th generation)", isiPad: true),
            "uma versão mais recente do iPadOS"
        )
    }
}
