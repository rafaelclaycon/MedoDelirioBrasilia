@testable import Medo_e_Delírio
import XCTest

class PodiumTests: XCTestCase {

    var networkRabbitStub: NetworkRabbitStub!
    var databaseSpy: LocalDatabaseSpy!
    var sut: Podium!
    
    override func setUp() {
        super.setUp()
        networkRabbitStub = .init()
        databaseSpy = .init()
        sut = Podium(database: databaseSpy, networkRabbit: networkRabbitStub)
    }

    override func tearDown() {
        sut = nil
        databaseSpy = nil
        networkRabbitStub = nil
        super.tearDown()
    }
    
    func test_exchangeShareCountStats_whenServerIsOffline_shouldReturnInfoString() throws {
        let e = expectation(description: "exchangeShareCountStats")
        var testBoolResult = true
        var testStringResult = ""
        
        networkRabbitStub.serverShouldBeUnavailable = true
        
        sut.exchangeShareCountStatsWithTheServer { serverIsAvailable, resultString in
            testBoolResult = serverIsAvailable
            testStringResult = resultString
            e.fulfill()
        }
        
        waitForExpectations(timeout: 5.0) { error in
            if let error = error {
                XCTFail("timeout errored: \(error)")
            }
            XCTAssertFalse(testBoolResult)
            XCTAssertEqual(testStringResult, "Servidor não disponível.")
        }
    }

    func test_exchangeShareCountStats_whenThereIsntAnythingToSendOrDownload_shouldAvoidPostingAndNotSaveAnythingLocally() throws {
        
    }

}
