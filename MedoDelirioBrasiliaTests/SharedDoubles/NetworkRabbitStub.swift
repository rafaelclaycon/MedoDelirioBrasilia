@testable import MedoDelirio
import Foundation

class NetworkRabbitStub: NetworkRabbitProtocol {

    var serverPath: String
    
    var serverShouldBeUnavailable = false
    var fetchUpdateEventsResult: SyncResult = .nothingToUpdate
    var retroStartingVersion: String?

    init() {
        serverPath = ""
    }
    
    func checkServerStatus(completionHandler: @escaping (Bool) -> Void) {
        completionHandler(!serverShouldBeUnavailable)
    }
    
    func getSoundShareCountStats(timeInterval: TrendsTimeInterval, completionHandler: @escaping ([ServerShareCountStat]?, NetworkRabbitError?) -> Void) {
        completionHandler(nil, nil)
    }
    
    func post(shareCountStat: ServerShareCountStat, completionHandler: @escaping (Bool, String) -> Void) {
        completionHandler(false, "")
    }
    
    func post(clientDeviceInfo: ClientDeviceInfo, completionHandler: @escaping (Bool?, NetworkRabbitError?) -> Void) {
        completionHandler(nil, nil)
    }
    
    func post(bundleIdLog: ServerShareBundleIdLog, completionHandler: @escaping (Bool, String) -> Void) {
        completionHandler(false, "")
    }
    
    func fetchUpdateEvents(from lastDate: String) async throws -> [MedoDelirio.UpdateEvent] {
        switch fetchUpdateEventsResult {
        default:
            return []
        }
    }

    func retroStartingVersion() async -> String? {
        return retroStartingVersion
    }
}
