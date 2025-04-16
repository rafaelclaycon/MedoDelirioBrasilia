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

    struct FakeServerSound: MedoContentProtocol {

        var id: String
        var title: String
        var subtitle: String = ""
        var description: String = ""
        var duration: Double = 0.0
        var dateAdded: Date? = nil
        var isFromServer: Bool? = true
        var type: MediaType = .sound
        var authorId: String = ""
        var isOffensive: Bool = false

        func fileURL() throws -> URL {
            Bundle(for: VideoMakerTests.self).url(forResource: "A9AFA060-B5E9-4A76-9E8C-12DB5DED51C5", withExtension: "mp3")!
        }
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

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testCreateVideo_whenTwitterVideoWithKnownProblematicSound_shouldReturnVideoURL() throws {
        let expectation = self.expectation(description: "Video generated successfully")
        let soundName = "Cadê os machos?"
        let sound = FakeServerSound(id: "A9AFA060-B5E9-4A76-9E8C-12DB5DED51C5", title: soundName)

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
