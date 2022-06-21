@testable import Medo_e_Delírio
import XCTest

class LoggerTests: XCTestCase {

    let sut = LocalDatabase()

    override func setUpWithError() throws {
        XCTAssertEqual(try sut.getUserShareLogCount(), 0)
    }

    override func tearDownWithError() throws {
        XCTAssertNoThrow(try sut.deleteAllUserShareLogs())
    }
    
//    func test_getTop5Sounds_whenNoSoundSharedYet_shouldReturnNil() {
//        XCTAssertNil(Podium.getTop5SoundsSharedByTheUser())
//    }
    
//    func test_getTop5Sounds_whenHasJustTwoSharedSounds_shouldReturn2TopChartItems() throws {
//        for log in ShareLogsDummy.getTwelveNaoFodeMermaoSoundShareLogs() {
//            try sut.insert(userShareLog: log)
//        }
//
//        try sut.insert(userShareLog: UserShareLog(installId: "76BE9811-D3D6-4DFC-8B37-6A8B83A1DF9A",
//                                                  contentId: "83301B63-DD4F-4844-A96D-06FC9F02ABDC",
//                                                  contentType: ContentType.sound.rawValue,
//                                                  dateTime: Date(),
//                                                  destination: ShareDestination.whatsApp.rawValue,
//                                                  destinationBundleId: "net.whatsapp.WhatsApp.ShareExtension"))
//
//        let logs = Podium.getTop5SoundsSharedByTheUser()
//        XCTAssertNotNil(logs)
//        XCTAssertEqual(logs!.count, 2)
//
//        XCTAssertEqual(logs![0].id, "1")
//        XCTAssertEqual(logs![0].contentName, "Não fode, mermão")
//        XCTAssertEqual(logs![0].contentAuthorName, "Away")
//        XCTAssertEqual(logs![0].shareCount, 12)
//
//        XCTAssertEqual(logs![1].id, "2")
//        XCTAssertEqual(logs![1].contentName, "É um merda")
//        XCTAssertEqual(logs![1].contentAuthorName, "Patrícia Miguez")
//        XCTAssertEqual(logs![1].shareCount, 1)
//    }
    
//    func test_getTop5Sounds_whenHasEnoughInformationForAll5_shouldReturn5TopChartItems() throws {
//        for log in ShareLogsDummy.getTwelveNaoFodeMermaoSoundShareLogs() {
//            try sut.insert(userShareLog: log)
//        }
//        for log in ShareLogsDummy.getFortySixBomDiaSoundShareLogs() {
//            try sut.insert(userShareLog: log)
//        }
//        for log in ShareLogsDummy.getThirtyEightComunistaSoundShareLogs() {
//            try sut.insert(userShareLog: log)
//        }
//        for log in ShareLogsDummy.getSixtySixEuNaoErreiNenhumaSoundShareLogs() {
//            try sut.insert(userShareLog: log)
//        }
//        for log in ShareLogsDummy.getSeventySixNaoVamosFalarSoundShareLogs() {
//            try sut.insert(userShareLog: log)
//        }
//        for log in ShareLogsDummy.getFortyFourDeuErradoSoundShareLogs() {
//            try sut.insert(userShareLog: log)
//        }
//        
//        let logs = Podium.getTop5SoundsSharedByTheUser()
//        XCTAssertNotNil(logs)
//        XCTAssertEqual(logs!.count, 5)
//        
//        XCTAssertEqual(logs![0].id, "1")
//        XCTAssertEqual(logs![0].contentName, "Não vamos falar de pornô aqui não")
//        XCTAssertEqual(logs![0].contentAuthorName, "Choque de Cultura")
//        XCTAssertEqual(logs![0].shareCount, 76)
//        
//        XCTAssertEqual(logs![1].id, "2")
//        XCTAssertEqual(logs![1].contentName, "Eu não errei nenhuma")
//        XCTAssertEqual(logs![1].contentAuthorName, "Bolsonaro")
//        XCTAssertEqual(logs![1].shareCount, 66)
//        
//        XCTAssertEqual(logs![2].id, "3")
//        XCTAssertEqual(logs![2].contentName, "Bom dia")
//        XCTAssertEqual(logs![2].contentAuthorName, "Mourão")
//        XCTAssertEqual(logs![2].shareCount, 46)
//        
//        XCTAssertEqual(logs![3].id, "4")
//        XCTAssertEqual(logs![3].contentName, "Deu errado")
//        XCTAssertEqual(logs![3].contentAuthorName, "Samuel Mariano")
//        XCTAssertEqual(logs![3].shareCount, 44)
//        
//        XCTAssertEqual(logs![4].id, "5")
//        XCTAssertEqual(logs![4].contentName, "Comunista")
//        XCTAssertEqual(logs![4].contentAuthorName, "Meme")
//        XCTAssertEqual(logs![4].shareCount, 38)
//    }
    
    // MARK: - Server Logs
    
    func test_getShareStatsForServer_whenHasALotOfData_shouldReturnShareCountsByUniqueContentId() throws {
        for log in ShareLogsDummy.getTwelveNaoFodeMermaoSoundShareLogs() {
            try sut.insert(userShareLog: log)
        }
        for log in ShareLogsDummy.getFortySixBomDiaSoundShareLogs() {
            try sut.insert(userShareLog: log)
        }
        for log in ShareLogsDummy.getThirtyEightComunistaSoundShareLogs() {
            try sut.insert(userShareLog: log)
        }
        for log in ShareLogsDummy.getSixtySixEuNaoErreiNenhumaSoundShareLogs() {
            try sut.insert(userShareLog: log)
        }
        for log in ShareLogsDummy.getSeventySixNaoVamosFalarSoundShareLogs() {
            try sut.insert(userShareLog: log)
        }
        for log in ShareLogsDummy.getFortyFourDeuErradoSoundShareLogs() {
            try sut.insert(userShareLog: log)
        }
        for log in ShareLogsDummy.getFortyTwoEMentiraSoundShareLogs() {
            try sut.insert(userShareLog: log)
        }
        
        let stats = Logger.getShareCountStatsForServer()
        XCTAssertNotNil(stats)
        XCTAssertEqual(stats!.count, 7)
        
        XCTAssertEqual(stats![0].installId, ShareLogsDummy.installId)
        XCTAssertEqual(stats![0].contentId, ShareLogsDummy.naoVamosFalarDePornoAquiNaoContentId)
        XCTAssertEqual(stats![0].contentType, 0)
        XCTAssertEqual(stats![0].shareCount, 76)
    }

}
