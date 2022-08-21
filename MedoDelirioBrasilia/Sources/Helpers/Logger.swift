import UIKit

class Logger {

    static func logSharedSound(contentId: String, destination: ShareDestination, destinationBundleId: String) {
        let shareLog = UserShareLog(installId: UIDevice.identifiderForVendor,
                                    contentId: contentId,
                                    contentType: 0,
                                    dateTime: Date(),
                                    destination: destination.rawValue,
                                    destinationBundleId: destinationBundleId,
                                    sentToServer: false)
        try? database.insert(userShareLog: shareLog)
    }
    
    static func logSharedSong(contentId: String, destination: ShareDestination, destinationBundleId: String) {
        let shareLog = UserShareLog(installId: UIDevice.identifiderForVendor,
                                    contentId: contentId,
                                    contentType: 1,
                                    dateTime: Date(),
                                    destination: destination.rawValue,
                                    destinationBundleId: destinationBundleId,
                                    sentToServer: false)
        try? database.insert(userShareLog: shareLog)
    }
    
    static func getShareCountStatsForServer() -> [ServerShareCountStat]? {
        guard let items = try? database.getShareCountByUniqueContentId(), items.count > 0 else {
            return nil
        }
        return items
    }
    
    static func getUniqueBundleIdsForServer() -> [ServerShareBundleIdLog]? {
        guard let items = try? database.getUniqueBundleIdsThatWereSharedTo(), items.count > 0 else {
            return nil
        }
        return items
    }
    
    static func logNetworkCall(callType: Int,
                               requestUrl: String,
                               requestBody: String?,
                               response: String,
                               wasSuccessful: Bool) {
        let log = NetworkCallLog(callType: callType,
                                 requestBody: requestBody ?? .empty,
                                 response: response,
                                 dateTime: Date(),
                                 wasSuccessful: wasSuccessful)
        try? database.insert(networkCallLog: log)
    }
    
    static func logFavorites(favoriteCount: Int, callMoment: String, needsMigration: Bool) {
        let log = FavoriteLog(favoriteCount: favoriteCount,
                              dateTime: Date(),
                              appVersion: "\(Versioneer.appVersion) Build \(Versioneer.buildVersionNumber)",
                              deviceModel: UIDevice.modelName,
                              systemVersion: UIDevice.current.systemVersion,
                              callMoment: callMoment,
                              needsMigration: needsMigration,
                              installId: UIDevice.current.identifierForVendor?.uuidString ?? "")
        try? database.insert(favoriteLog: log)
    }

}
