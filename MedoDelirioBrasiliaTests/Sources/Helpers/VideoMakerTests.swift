//
//  VideoMakerTests.swift
//  MedoDelirioBrasiliaTests
//
//  Created by Rafael Schmitt on 21/09/24.
//

import XCTest
@testable import MedoDelirio

final class VideoMakerTests: XCTestCase {

    private var testImage: UIImage? {
        UIImage(named: "video_sample", in: Bundle(for: type(of: self)), compatibleWith: nil)
    }

    func testCreateVideo_whenTwitterVideoWithKnownToWorkSound_shouldReturnVideoURL() throws {
        let expectation = self.expectation(description: "Video generated successfully")
        let soundName = "Se insere no mesmo continente mental"
        let sound = Sound(
            title: soundName,
            filename: "Flavio Dino - Se insere no mesmo continente mental de quem acha que a terra e plana.mp3"
        )

        try VideoMaker.createVideo(
            from: sound,
            with: testImage!,
            exportType: .twitter
        ) { videoPath, error in
            if let error {
                return XCTFail(error.localizedDescription)
            }
            XCTAssertTrue(videoPath?.contains("Documents/\(soundName).mov") ?? false)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testCreateVideo_whenTwitterVideoWithKnownProblematicSound_shouldReturnVideoURL() throws {
        let expectation = self.expectation(description: "Video generated successfully")
        let soundName = "Cadê os machos?"
        let sound = Sound(
            title: soundName,
            filename: "Flavio Dino - Se insere no mesmo continente mental de quem acha que a terra e plana.mp3"
        )

        try VideoMaker.createVideo(
            from: sound,
            with: testImage!,
            exportType: .twitter
        ) { videoPath, error in
            if let error {
                return XCTFail(error.localizedDescription)
            }
            XCTAssertTrue(videoPath?.contains("Documents/\(soundName).mov") ?? false)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

//    func testCreateVideo_whenTwitterVideoWithKnownToWorkSound_shouldReturnVideoURL() async throws {
//        let soundName = "Se insere no mesmo continente mental"
//        let sound = Sound(
//            title: soundName,
//            filename: "Flavio Dino - Se insere no mesmo continente mental de quem acha que a terra e plana.mp3"
//        )
//
//        let videoPath = try await VideoMaker.createVideo(
//            from: sound,
//            with: testImage!,
//            exportType: .twitter
//        )
//
//        XCTAssertTrue(videoPath?.contains("Documents/\(soundName).mov") ?? false)
//    }
//
//    func testCreateVideo_whenTwitterVideoWithKnownProblematicSound_shouldReturnVideoURL() async throws {
//        let soundName = "Cadê os machos?"
//        let sound = Sound(
//            title: soundName,
//            filename: "Flavio Dino - Se insere no mesmo continente mental de quem acha que a terra e plana.mp3"
//        )
//
//        let videoPath = try await VideoMaker.createVideo(
//            from: sound,
//            with: testImage!,
//            exportType: .twitter
//        )
//
//        XCTAssertTrue(videoPath?.contains("Documents/\(soundName).mov") ?? false)
//    }
}
