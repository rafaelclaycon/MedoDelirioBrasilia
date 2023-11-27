//
//  UpdateIncentiveTests.swift
//  MedoDelirioBrasiliaTests
//
//  Created by Rafael Schmitt on 26/11/23.
//

import XCTest
@testable import MedoDelirio

final class UpdateIncentiveTests: XCTestCase {

    func testShouldDisplayBanner_whenIsiPhone8Running15_ShouldReturnTrue() throws {
        XCTAssertTrue(
            UpdateIncentive.shouldDisplayBanner(currentSystemVersion: "15.2", deviceModel: "iPhone 8")
        )
    }

    func testShouldDisplayBanner_whenIsiPhone11Running15_ShouldReturnTrue() throws {
        XCTAssertTrue(
            UpdateIncentive.shouldDisplayBanner(currentSystemVersion: "15.2.1", deviceModel: "iPhone 11")
        )
    }

    func testShouldDisplayBanner_whenIsiPhone7Running15_ShouldReturnFalse() throws {
        XCTAssertFalse(
            UpdateIncentive.shouldDisplayBanner(currentSystemVersion: "15.8", deviceModel: "iPhone 7")
        )
    }

    func testShouldDisplayBanner_whenIsiPhoneSE1Running15_ShouldReturnFalse() throws {
        XCTAssertFalse(
            UpdateIncentive.shouldDisplayBanner(currentSystemVersion: "15.5", deviceModel: "iPhone SE")
        )
    }

    func testShouldDisplayBanner_whenIsiPad5thGenRunning15_ShouldReturnTrue() throws {
        XCTAssertTrue(
            UpdateIncentive.shouldDisplayBanner(currentSystemVersion: "15.5", deviceModel: "iPad (5th generation)", isiPad: true)
        )
    }

    func testShouldDisplayBanner_whenIsiPadAir2Running15_ShouldReturnFalse() throws {
        XCTAssertFalse(
            UpdateIncentive.shouldDisplayBanner(currentSystemVersion: "15.7.8", deviceModel: "iPad Air 2", isiPad: true)
        )
    }

    func testShouldDisplayBanner_whenIsiPadAir2Running15_ShouldReturnTrue() throws {
        XCTAssertTrue(
            UpdateIncentive.shouldDisplayBanner(currentSystemVersion: "15.5", deviceModel: "iPad Air (5th generation)", isiPad: true)
        )
    }
}

// MARK: - Max Supported Version
extension UpdateIncentiveTests {

    func testMaxSupportedVersion_whenIsiPhone8_ShouldReturn16() throws {
        XCTAssertEqual(
            UpdateIncentive.maxSupportedVersion(deviceModel: "iPhone 8"),
            "iOS 16"
        )
    }

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
