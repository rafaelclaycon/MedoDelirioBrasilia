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

    func get<T>(from url: URL) async throws -> T where T : Decodable, T : Encodable {
        return T.self as! T
    }

    func serverIsAvailable() async -> Bool {
        return !serverShouldBeUnavailable
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

    func post<T>(to url: URL, body: T) async throws where T : Encodable {
        //
    }
}
