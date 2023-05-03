//
//  SoundServiceTests.swift
//  MedoDelirioBrasiliaTests
//
//  Created by Rafael Schmitt on 03/05/23.
//

import XCTest
@testable import MedoDelirio

final class SoundServiceTests: XCTestCase {
    
    private var sut: SoundService!
    
    private var connectionManager: ConnectionManagerStub!
    private var networkRabbit: NetworkRabbitStub!
    
    override func setUp() {
        connectionManager = ConnectionManagerStub()
        networkRabbit = NetworkRabbitStub()
    }
    
    override func tearDown() {
        sut = nil
        networkRabbit = nil
        connectionManager = nil
        super.tearDown()
    }
    
    func test_syncWithServer_noInternetConnection() async throws {
        connectionManager.hasConnectivityResult = false
        sut = SoundService(connectionManager: connectionManager, networkRabbit: networkRabbit)
        
        let expectation = XCTestExpectation()
        
        let result = await sut.syncWithServer()
        
        XCTAssertEqual(result, .noInternet)
        
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 2)
    }
    
    func test_syncWithServer_noChanges() async throws {
        networkRabbit.fetchUpdateEventsResult = .nothingToUpdate
        sut = SoundService(connectionManager: connectionManager, networkRabbit: networkRabbit)

        let expectation = XCTestExpectation()
        
        let result = await sut.syncWithServer()
        
        XCTAssertEqual(result, .nothingToUpdate)
        
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 2)
    }
    
    func test_syncWithServer_serverError() async throws {
        networkRabbit.fetchUpdateEventsResult = .updateError
        sut = SoundService(connectionManager: connectionManager, networkRabbit: networkRabbit)

        let expectation = XCTestExpectation()
        
        let result = await sut.syncWithServer()
        
        XCTAssertEqual(result, .updateError)
        
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 2)
    }
}
