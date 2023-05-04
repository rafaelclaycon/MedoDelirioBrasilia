//
//  SyncServiceTests.swift
//  MedoDelirioBrasiliaTests
//
//  Created by Rafael Schmitt on 03/05/23.
//

import XCTest
@testable import MedoDelirio

final class SyncServiceTests: XCTestCase {
    
    private var sut: SyncService!
    
    private var connectionManager: ConnectionManagerStub!
    private var networkRabbit: NetworkRabbitStub!
    private var localDatabase: LocalDatabaseStub!
    
    override func setUp() {
        connectionManager = ConnectionManagerStub()
        networkRabbit = NetworkRabbitStub()
        localDatabase = LocalDatabaseStub()
    }
    
    override func tearDown() {
        sut = nil
        localDatabase = nil
        networkRabbit = nil
        connectionManager = nil
        super.tearDown()
    }
    
    func test_syncWithServer_noInternetConnection() async throws {
        connectionManager.hasConnectivityResult = false
        sut = SyncService(connectionManager: connectionManager, networkRabbit: networkRabbit, localDatabase: localDatabase)
        
        let expectation = XCTestExpectation()
        
        let result = await sut.syncWithServer()
        
        XCTAssertEqual(result, .noInternet)
        
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 2)
    }
    
    func test_syncWithServer_noChanges() async throws {
        networkRabbit.fetchUpdateEventsResult = .nothingToUpdate
        
        sut = SyncService(connectionManager: connectionManager, networkRabbit: networkRabbit, localDatabase: localDatabase)

        let expectation = XCTestExpectation()
        
        let result = await sut.syncWithServer()
        
        XCTAssertEqual(result, .nothingToUpdate)
        
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 2)
    }
    
    func test_syncWithServer_serverError() async throws {
        networkRabbit.fetchUpdateEventsResult = .updateError
        
        sut = SyncService(connectionManager: connectionManager, networkRabbit: networkRabbit, localDatabase: localDatabase)

        let expectation = XCTestExpectation()
        
        let result = await sut.syncWithServer()
        
        XCTAssertEqual(result, .updateError)
        
        expectation.fulfill()
        
        await fulfillment(of: [expectation], timeout: 2)
    }
}
