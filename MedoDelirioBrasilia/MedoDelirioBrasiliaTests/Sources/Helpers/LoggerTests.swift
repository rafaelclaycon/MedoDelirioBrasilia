@testable import MedoDelirioBrasilia
import XCTest

class LoggerTests: XCTestCase {

    let sut = LocalDatabase()

    override func setUpWithError() throws {
        XCTAssertEqual(try sut.getShareLogCount(), 0)
    }

    override func tearDownWithError() throws {
        XCTAssertNoThrow(try sut.deleteAllShareLogs())
    }
    
    func test_getTop5Sounds_whenNoSoundSharedYet_shouldReturnNil() {
        XCTAssertNil(Logger.getTop5Sounds())
    }
    
    func test_getTop5Sounds_whenHasEnoughInformationForAll5_shouldReturn5TopChartItems() throws {
        for log in DummyShareLogs.getShitloadOfSoundShareLogs() {
            try sut.insert(shareLog: log)
        }
        
        try sut.insert(shareLog: ShareLog(installId: "76BE9811-D3D6-4DFC-8B37-6A8B83A1DF9A",
                                          contentId: "83301B63-DD4F-4844-A96D-06FC9F02ABDC",
                                          contentType: ContentType.sound.rawValue,
                                          dateTime: Date(),
                                          destination: ShareDestination.whatsApp.rawValue,
                                          destinationBundleId: "net.whatsapp.WhatsApp.ShareExtension"))
        
        let logs = Logger.getTop5Sounds()
        XCTAssertNotNil(logs)
        XCTAssertEqual(logs!.count, 2)
        XCTAssertEqual(logs![0].contentName, "Não fode, mermão")
        XCTAssertEqual(logs![0].shareCount, 10)
        XCTAssertEqual(logs![1].contentName, "É um merda")
        XCTAssertEqual(logs![1].shareCount, 1)
    }

}
