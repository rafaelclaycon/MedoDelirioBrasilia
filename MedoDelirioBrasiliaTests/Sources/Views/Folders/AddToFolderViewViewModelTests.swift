//
//  AddToFolderViewViewModelTests.swift
//  MedoDelirioBrasiliaTests
//
//  Created by Rafael Claycon Schmitt on 01/02/23.
//

@testable import MedoDelirio
import XCTest

final class AddToFolderViewViewModelTests: XCTestCase {

    private var localDatabaseStub: LocalDatabaseStub!
    private var sut: AddToFolderViewViewModel!
    
    override func tearDown() {
        localDatabaseStub = nil
        sut = nil
    }
    
    func test_canBeAddedToFolder_whenSingleSoundAndNotInFolder_shouldReturnArrayWithSameSound() throws {
        localDatabaseStub = LocalDatabaseStub()
        
        sut = AddToFolderViewViewModel(database: localDatabaseStub)
        
        var mockSounds = [Sound]()
        mockSounds.append(Sound(id: "123", title: "Deu errado"))
        
        let result = sut.canBeAddedToFolder(sounds: mockSounds, folderId: "")
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first!.id, "123")
    }
    
    func test_canBeAddedToFolder_whenSingleSoundAndIsInFolder_shouldReturnEmptyArray() throws {
        localDatabaseStub = LocalDatabaseStub()
        localDatabaseStub.contentInsideFolder = [String]()
        localDatabaseStub.contentInsideFolder?.append("123")
        
        sut = AddToFolderViewViewModel(database: localDatabaseStub)
        
        var mockSounds = [Sound]()
        mockSounds.append(Sound(id: "123", title: "Deu errado"))
        
        let result = sut.canBeAddedToFolder(sounds: mockSounds, folderId: "")
        
        XCTAssertEqual(result.count, 0)
    }
    
    func test_canBeAddedToFolder_whenMultipleSoundsAndNoneAreInFolder_shouldReturnAllSoundsOnArray() throws {
        localDatabaseStub = LocalDatabaseStub()
        
        sut = AddToFolderViewViewModel(database: localDatabaseStub)
        
        var mockSounds = [Sound]()
        mockSounds.append(Sound(id: "123", title: "Deu errado"))
        mockSounds.append(Sound(id: "456", title: "Aí eu acho exagero"))
        mockSounds.append(Sound(id: "789", title: "Senhores, selva"))
        mockSounds.append(Sound(id: "101112", title: "Acabou o flashback"))
        
        let result = sut.canBeAddedToFolder(sounds: mockSounds, folderId: "")
        
        XCTAssertEqual(result.count, 4)
        XCTAssertEqual(result.first!.id, "123")
        XCTAssertEqual(result[1].id, "456")
        XCTAssertEqual(result[2].id, "789")
        XCTAssertEqual(result.last!.id, "101112")
    }
    
    func test_canBeAddedToFolder_whenMultipleSoundsAndAllAreInFolder_shouldReturnEmptyArray() throws {
        localDatabaseStub = LocalDatabaseStub()
        localDatabaseStub.contentInsideFolder = [String]()
        localDatabaseStub.contentInsideFolder?.append("123")
        localDatabaseStub.contentInsideFolder?.append("456")
        localDatabaseStub.contentInsideFolder?.append("789")
        localDatabaseStub.contentInsideFolder?.append("101112")
        
        sut = AddToFolderViewViewModel(database: localDatabaseStub)
        
        var mockSounds = [Sound]()
        mockSounds.append(Sound(id: "123", title: "Deu errado"))
        mockSounds.append(Sound(id: "456", title: "Aí eu acho exagero"))
        mockSounds.append(Sound(id: "789", title: "Senhores, selva"))
        mockSounds.append(Sound(id: "101112", title: "Acabou o flashback"))
        
        let result = sut.canBeAddedToFolder(sounds: mockSounds, folderId: "")
        
        XCTAssertEqual(result.count, 0)
    }
    
    func test_canBeAddedToFolder_whenMultipleSoundsAndSomeAreInFolder_shouldReturnArrayWithTheOnesThatAreNotOnTheFolder() throws {
        localDatabaseStub = LocalDatabaseStub()
        localDatabaseStub.contentInsideFolder = [String]()
        localDatabaseStub.contentInsideFolder?.append("123")
        localDatabaseStub.contentInsideFolder?.append("789")
        
        sut = AddToFolderViewViewModel(database: localDatabaseStub)
        
        var mockSounds = [Sound]()
        mockSounds.append(Sound(id: "123", title: "Deu errado"))
        mockSounds.append(Sound(id: "456", title: "Aí eu acho exagero"))
        mockSounds.append(Sound(id: "789", title: "Senhores, selva"))
        mockSounds.append(Sound(id: "101112", title: "Acabou o flashback"))
        
        let result = sut.canBeAddedToFolder(sounds: mockSounds, folderId: "")
        
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result.first!.id, "456")
        XCTAssertEqual(result.last!.id, "101112")
    }

}
