@testable import Medo_e_Delírio
import XCTest

class LocalDatabaseTests: XCTestCase {

    let sut = LocalDatabase()
    let testFavorites: [Favorite]? = nil

    override func setUpWithError() throws {
        XCTAssertEqual(try sut.getFavoriteCount(), 0)
    }

    override func tearDownWithError() throws {
        XCTAssertNoThrow(try sut.deleteAllFavorites())
    }

    func test_insertFavorite_whenInsertsFavorite_shouldReturnFavoriteCount1() {
        let favorite = Favorite(contentId: "557C08FF-F80F-4E82-99A6-956D14FC881B", dateAdded: Date())
        XCTAssertNoThrow(try sut.insert(favorite: favorite))
        XCTAssertEqual(try sut.getFavoriteCount(), 1)
    }
    
    func test_exists_whenFavoriteDoesNotExist_shouldReturnFalse() {
        let favorite = Favorite(contentId: "557C08FF-F80F-4E82-99A6-956D14FC881B", dateAdded: Date())
        
        XCTAssertNoThrow(try sut.insert(favorite: favorite))
        
        XCTAssertEqual(try sut.exists(contentId: "494494BE-7AE6-4B8F-BB6D-096BB59E9B88"), false)
    }
    
    func test_exists_whenFavoriteExists_shouldReturnTrue() {
        let favorite = Favorite(contentId: "557C08FF-F80F-4E82-99A6-956D14FC881B", dateAdded: Date())
        
        XCTAssertNoThrow(try sut.insert(favorite: favorite))
        
        XCTAssertEqual(try sut.exists(contentId: "557C08FF-F80F-4E82-99A6-956D14FC881B"), true)
    }
    
    func test_insert_whenFavoriteAlreadyExists_shouldReturn() throws {
        let favorite = Favorite(contentId: "557C08FF-F80F-4E82-99A6-956D14FC881B", dateAdded: Date())
        
        XCTAssertNoThrow(try sut.insert(favorite: favorite))
        
        XCTAssertThrowsError(try sut.insert(favorite: favorite))
    }

}
