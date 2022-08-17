@testable import MedoDelirio
import XCTest

class LocalDatabaseTests: XCTestCase {

    let sut = LocalDatabase()
    //let testFavorites: [Favorite]? = nil

    override func setUpWithError() throws {
        XCTAssertEqual(try sut.getFavoriteCount(), 0)
        XCTAssertEqual(try sut.getUserShareLogCount(), 0)
    }

    override func tearDownWithError() throws {
        XCTAssertNoThrow(try sut.deleteAllFavorites())
        XCTAssertNoThrow(try sut.deleteAllUserShareLogs())
    }
    
    // MARK: - Favorites
    
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
    
    // MARK: - User Share Logs
    
    func test_insertUserShareLog_whenInsertIsSuccessful_shouldReturnShareLogCount1() {
        let log = UserShareLog(installId: "76BE9811-D3D6-4DFC-8B37-6A8B83A1DF9A",
                               contentId: "6E4251F8-FE50-46E1-B8ED-6E24CEA1EB15",
                               contentType: ContentType.sound.rawValue,
                               dateTime: Date(),
                               destination: ShareDestination.whatsApp.rawValue,
                               destinationBundleId: "net.whatsapp.WhatsApp.ShareExtension")
        XCTAssertNoThrow(try sut.insert(userShareLog: log))
        XCTAssertEqual(try sut.getUserShareLogCount(), 1)
    }
    
    // MARK: - User Share Logs
    
//    func test_insertAudienceSharingStat_whenInsertIsSuccessful_shouldReturnSharingStatCount1() {
//        let stat = AudienceShareCountStat(contentId: "6E4251F8-FE50-46E1-B8ED-6E24CEA1EB15",
//                                          contentType: ContentType.sound.rawValue,
//                                          shareCount: 16)
//        XCTAssertNoThrow(try sut.insert(audienceStat: stat))
//        XCTAssertEqual(try sut.getAudienceSharingStatCount(), 1)
//    }

}
