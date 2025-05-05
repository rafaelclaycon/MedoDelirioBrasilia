@testable import MedoDelirio
import XCTest

class PodiumTests: XCTestCase {

    var apiClientStub: FakeAPIClient!
    var databaseSpy: LocalDatabaseSpy!
    var sut: Podium!
    
    override func setUp() {
        super.setUp()
        apiClientStub = .init()
        databaseSpy = .init()
        sut = Podium(database: databaseSpy, apiClient: apiClientStub)
    }

    override func tearDown() {
        sut = nil
        databaseSpy = nil
        apiClientStub = nil
        super.tearDown()
    }
    
//    func test_exchangeShareCountStats_whenServerIsOffline_shouldReturnInfoString() throws {
//        let e = expectation(description: "exchangeShareCountStats")
//        var testBoolResult: Podium.ShareCountStatServerExchangeResult = .successful
//        var testStringResult = ""
//        
//        apiClientStub.serverShouldBeUnavailable = true
//        
//        sut.sendShareCountStatsToServer { result, resultString in
//            testBoolResult = result
//            testStringResult = resultString
//            e.fulfill()
//        }
//        
//        waitForExpectations(timeout: 5.0) { error in
//            if let error = error {
//                XCTFail("timeout errored: \(error)")
//            }
//            XCTAssertEqual(testBoolResult, .failed)
//            XCTAssertEqual(testStringResult, "Servidor não disponível.")
//        }
//    }

    func test_exchangeShareCountStats_whenThereIsntAnythingToSendOrDownload_shouldAvoidPostingAndNotSaveAnythingLocally() throws {
        
    }
}
