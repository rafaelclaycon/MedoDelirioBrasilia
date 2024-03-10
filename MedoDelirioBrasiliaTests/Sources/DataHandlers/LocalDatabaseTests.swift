//
//  LocalDatabaseTests.swift
//  MedoDelirioBrasiliaTests
//
//  Created by Rafael Schmitt on 24/05/22.
//

import XCTest
@testable import MedoDelirio

final class LocalDatabaseTests: XCTestCase {

    private var sut: LocalDatabase!

    override func setUp() {
        super.setUp()
        sut = LocalDatabase()
//        XCTAssertEqual(try sut.favoriteCount(), 0)
//        XCTAssertEqual(try sut.getUserShareLogCount(), 0)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Favorites
    
//    func test_insertFavorite_whenInsertsFavorite_shouldReturnFavoriteCount1() {
//        let favorite = Favorite(contentId: "557C08FF-F80F-4E82-99A6-956D14FC881B", dateAdded: Date())
//        XCTAssertNoThrow(try sut.insert(favorite: favorite))
//        XCTAssertEqual(try sut.favoriteCount(), 1)
//    }
//    
//    func test_exists_whenFavoriteDoesNotExist_shouldReturnFalse() {
//        let favorite = Favorite(contentId: "557C08FF-F80F-4E82-99A6-956D14FC881B", dateAdded: Date())
//        
//        XCTAssertNoThrow(try sut.insert(favorite: favorite))
//        
//        XCTAssertEqual(try sut.exists(contentId: "494494BE-7AE6-4B8F-BB6D-096BB59E9B88"), false)
//    }
//    
//    func test_exists_whenFavoriteExists_shouldReturnTrue() {
//        let favorite = Favorite(contentId: "557C08FF-F80F-4E82-99A6-956D14FC881B", dateAdded: Date())
//        
//        XCTAssertNoThrow(try sut.insert(favorite: favorite))
//        
//        XCTAssertEqual(try sut.exists(contentId: "557C08FF-F80F-4E82-99A6-956D14FC881B"), true)
//    }
//    
//    func test_insert_whenFavoriteAlreadyExists_shouldReturn() throws {
//        let favorite = Favorite(contentId: "557C08FF-F80F-4E82-99A6-956D14FC881B", dateAdded: Date())
//        
//        XCTAssertNoThrow(try sut.insert(favorite: favorite))
//        
//        XCTAssertThrowsError(try sut.insert(favorite: favorite))
//    }
    
    // MARK: - User Share Logs
    
//    func test_insertUserShareLog_whenInsertIsSuccessful_shouldReturnShareLogCount1() {
//        let log = UserShareLog(installId: "76BE9811-D3D6-4DFC-8B37-6A8B83A1DF9A",
//                               contentId: "6E4251F8-FE50-46E1-B8ED-6E24CEA1EB15",
//                               contentType: ContentType.sound.rawValue,
//                               dateTime: Date(),
//                               destination: ShareDestination.whatsApp.rawValue,
//                               destinationBundleId: "net.whatsapp.WhatsApp.ShareExtension")
//        XCTAssertNoThrow(try sut.insert(userShareLog: log))
//        XCTAssertEqual(try sut.getUserShareLogCount(), 1)
//    }
    
    // MARK: - User Share Logs
    
//    func test_insertAudienceSharingStat_whenInsertIsSuccessful_shouldReturnSharingStatCount1() {
//        let stat = AudienceShareCountStat(contentId: "6E4251F8-FE50-46E1-B8ED-6E24CEA1EB15",
//                                          contentType: ContentType.sound.rawValue,
//                                          shareCount: 16)
//        XCTAssertNoThrow(try sut.insert(audienceStat: stat))
//        XCTAssertEqual(try sut.getAudienceSharingStatCount(), 1)
//    }

}

// MARK: - Last Update Date

extension LocalDatabaseTests {

    func testDateTimeOfLastUpdate_whenNoUpdates_shouldReturnAllString() {
        XCTAssertEqual(sut.dateTimeOfLastUpdate(), "all")
    }

    func testDateTimeOfLastUpdate_whenSomeUpdates_shouldReturnDateTimeStringOfLatestUpdate() throws {
        try sut.insert(updateEvent: .init(contentId: "1", dateTime: "2024-01-27T14:17:13.231Z", mediaType: .sound, eventType: .created))
        try sut.insert(updateEvent: .init(contentId: "1", dateTime: "2024-01-30T16:13:32.159Z", mediaType: .sound, eventType: .created))
        try sut.insert(updateEvent: .init(contentId: "1", dateTime: "2024-01-30T16:14:11.155Z", mediaType: .sound, eventType: .created))
        XCTAssertEqual(sut.dateTimeOfLastUpdate(), "2024-01-30T16:14:11.155Z")
    }
}
