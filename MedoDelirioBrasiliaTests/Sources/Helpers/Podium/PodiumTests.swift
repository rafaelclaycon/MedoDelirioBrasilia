@testable import MedoDelirio
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
        var testBoolResult: Podium.ShareCountStatServerExchangesResult = .successful
        var testStringResult = ""
        
        networkRabbitStub.serverShouldBeUnavailable = true
        
        sut.exchangeShareCountStatsWithTheServer(timeInterval: .allTime) { result, resultString in
            testBoolResult = result
            testStringResult = resultString
            e.fulfill()
        }
        
        waitForExpectations(timeout: 5.0) { error in
            if let error = error {
                XCTFail("timeout errored: \(error)")
            }
            XCTAssertEqual(testBoolResult, .failed)
            XCTAssertEqual(testStringResult, "Servidor não disponível.")
        }
    }

    func test_exchangeShareCountStats_whenThereIsntAnythingToSendOrDownload_shouldAvoidPostingAndNotSaveAnythingLocally() throws {
        
    }

}
