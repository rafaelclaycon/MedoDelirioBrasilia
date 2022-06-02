@testable import Medo_e_Delírio
import XCTest

class NetworkRabbitTests: XCTestCase {

    func test_getHelloFromServer_whenCallIsOkAndServerIsRunning_shouldReturnCorrectString() throws {
        let e = expectation(description: "Server call")
        var testResult = ""
        
        NetworkRabbit.getHelloFromServer { result in
            guard result.contains("Failed") == false else {
                fatalError(result)
            }
            testResult = result
            e.fulfill()
        }
        
        waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("timeout errored: \(error)")
            }
            XCTAssertEqual(testResult, "Hello, MedoDelirioBrasilia!")
        }
    }

}
