@testable import Medo_e_Delírio
import XCTest

class NetworkRabbitTests: XCTestCase {

    private var sut: NetworkRabbit!
    
    override func setUp() {
        super.setUp()
        sut = NetworkRabbit(serverPath: "http://170.187.145.233:8080/api/v1/")
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_getHelloFromServer_whenCallIsOkAndServerIsRunning_shouldReturnCorrectString() throws {
        let e = expectation(description: "Server call")
        var testResult = ""
        
        sut.getHelloFromServer { result in
            guard result.contains("Failed") == false else {
                fatalError(result)
            }
            testResult = result
            e.fulfill()
        }
        
        waitForExpectations(timeout: 5.0) { error in
            if let error = error {
                XCTFail("timeout errored: \(error)")
            }
            XCTAssertEqual(testResult, "Hello, MedoDelirioBrasilia!")
        }
    }
    
//    func test_postShareCountStats_whenCallIsOkAndServerIsRunning_shouldReturnCorrectData() throws {
//        let e = expectation(description: "Server call")
//        var testResult = ""
//
//        let mockStat = ServerShareCountStat(installId: DummyShareLogs.installId, contentId: DummyShareLogs.bomDiaContentId, contentType: 0, shareCount: 10)
//
//        sut.post(shareCountStat: mockStat) { result in
//            guard result.contains("Failed") == false else {
//                fatalError(result)
//            }
//            testResult = result
//            e.fulfill()
//        }
//
//        waitForExpectations(timeout: 5.0) { error in
//            if let error = error {
//                XCTFail("timeout errored: \(error)")
//            }
//            XCTAssertEqual(testResult, DummyShareLogs.bomDiaContentId)
//        }
//    }

}
