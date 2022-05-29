import UIKit

class Logger {

    static func logSharedSound(contentId: String, destination: ShareDestination, destinationBundleId: String) {
        let shareLog = ShareLog(installId: UIDevice.current.identifierForVendor?.uuidString ?? "",
                                contentId: contentId,
                                contentType: 0,
                                dateTime: Date(),
                                destination: destination.rawValue,
                                destinationBundleId: destinationBundleId)
        try? database.insert(shareLog: shareLog)
    }
    
//    static func getTop5() -> [TopChartItem] {
//        
//    }

}
