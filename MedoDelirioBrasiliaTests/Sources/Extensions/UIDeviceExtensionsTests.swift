//
//  UIDeviceExtensionsTests.swift
//  MedoDelirioBrasiliaTests
//
//  Created by Rafael Schmitt on 06/10/24.
//

import XCTest
@testable import MedoDelirio

final class UIDeviceExtensionsTests: XCTestCase {

    func testSupportsiOSiPadOS18_whenIsiPhoneXR_shouldReturnTrue() throws {
        XCTAssertTrue(UIDevice.supportsiOSiPadOS18("iPhone XR"))
    }

    func testSupportsiOSiPadOS18_whenIsiPhone13_shouldReturnTrue() throws {
        XCTAssertTrue(UIDevice.supportsiOSiPadOS18("iPhone 13"))
    }

    func testSupportsiOSiPadOS18_whenIsiPadAir3rdGen_shouldReturnTrue() throws {
        XCTAssertTrue(UIDevice.supportsiOSiPadOS18(isiPad: true, "iPad Air (3rd generation)"))
    }

    func testSupportsiOSiPadOS18_whenIsMac_shouldReturnFalse() throws {
        XCTAssertFalse(UIDevice.supportsiOSiPadOS18(isMac: true, "Mac"))
    }
}
