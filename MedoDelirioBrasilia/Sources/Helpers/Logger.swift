import UIKit

class Logger {

    static func logSharedSound(contentId: String, destination: ShareDestination, destinationBundleId: String) {
        let shareLog = UserShareLog(installId: UIDevice.customInstallId,
                                    contentId: contentId,
                                    contentType: ContentType.sound.rawValue,
                                    dateTime: Date(),
                                    destination: destination.rawValue,
                                    destinationBundleId: destinationBundleId,
                                    sentToServer: false)
        try? LocalDatabase.shared.insert(userShareLog: shareLog)
    }
    
    static func logSharedSong(contentId: String, destination: ShareDestination, destinationBundleId: String) {
        let shareLog = UserShareLog(installId: UIDevice.customInstallId,
                                    contentId: contentId,
                                    contentType: ContentType.song.rawValue,
                                    dateTime: Date(),
                                    destination: destination.rawValue,
                                    destinationBundleId: destinationBundleId,
                                    sentToServer: false)
        try? LocalDatabase.shared.insert(userShareLog: shareLog)
    }
    
    static func logSharedVideoFromSound(contentId: String, destination: ShareDestination, destinationBundleId: String) {
        let shareLog = UserShareLog(installId: UIDevice.customInstallId,
                                    contentId: contentId,
                                    contentType: ContentType.videoFromSound.rawValue,
                                    dateTime: Date(),
                                    destination: destination.rawValue,
                                    destinationBundleId: destinationBundleId,
                                    sentToServer: false)
        try? LocalDatabase.shared.insert(userShareLog: shareLog)
    }
    
    static func getShareCountStatsForServer() -> [ServerShareCountStat]? {
        guard let items = try? LocalDatabase.shared.getUserShareStatsNotSentToServer(), items.count > 0 else {
            return nil
        }
        return items
    }
    
    static func getUniqueBundleIdsForServer() -> [ServerShareBundleIdLog]? {
        guard let items = try? LocalDatabase.shared.getUniqueBundleIdsThatWereSharedTo(), items.count > 0 else {
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
        try? LocalDatabase.shared.insert(networkCallLog: log)
    }
    
    static func logSyncError(description: String, updateEventId: String) {
        let syncLog = SyncLog(logType: .error,
                              description: description,
                              updateEventId: updateEventId)
        LocalDatabase.shared.insert(syncLog: syncLog)
    }
    
    static func logSyncSuccess(description: String, updateEventId: String) {
        let syncLog = SyncLog(logType: .success,
                              description: description,
                              updateEventId: updateEventId)
        LocalDatabase.shared.insert(syncLog: syncLog)
    }
}
