@testable import MedoDelirio
import XCTest

class NetworkRabbitTests: XCTestCase {

    private var sut: NetworkRabbit!
    
    override func setUp() {
        super.setUp()
        sut = NetworkRabbit(serverPath: "http://localhost:8080/api/")
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_checkServerStatus_whenCallIsOkAndServerIsRunning_shouldReturnCorrectString() throws {
        let e = expectation(description: "Server call")
        var testResult = false
        
        sut.checkServerStatus { serverIsAvailable, returnString  in
            guard serverIsAvailable else {
                fatalError(returnString)
            }
            testResult = serverIsAvailable
            e.fulfill()
        }
        
        waitForExpectations(timeout: 5.0) { error in
            if let error = error {
                XCTFail("timeout errored: \(error)")
            }
            XCTAssertTrue(testResult)
        }
    }
    
//    func test_postShareCountStats_whenCallIsOkAndServerIsRunning_shouldReturnCorrectData() throws {
//        let e = expectation(description: "Server call")
//        var testResult = ""
//
//        let mockStat = ServerShareCountStat(installId: ShareLogsDummy.installId, contentId: ShareLogsDummy.bomDiaContentId, contentType: 0, shareCount: 10)
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
//            XCTAssertEqual(testResult, ShareLogsDummy.bomDiaContentId)
//        }
//    }

}
