//
//  AddToFolderViewViewModelTests.swift
//  MedoDelirioBrasiliaTests
//
//  Created by Rafael Claycon Schmitt on 01/02/23.
//

@testable import MedoDelirio
import XCTest

final class AddToFolderViewViewModelTests: XCTestCase {

    private var sut: AddToFolderViewViewModel!
    
    override func tearDown() {
        sut = nil
    }
    
    func test_soundIsNotYetOnFolder_whenSingleSoundAndNotOnFolder_shouldReturnFalse() throws {
        sut = AddToFolderViewViewModel()
        
        XCTFail()
    }

}
