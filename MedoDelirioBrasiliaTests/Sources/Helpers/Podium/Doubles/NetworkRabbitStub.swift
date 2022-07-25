@testable import MedoDelirio
import Foundation

class NetworkRabbitStub: NetworkRabbitProtocol {

    var serverShouldBeUnavailable = false
    
    func checkServerStatus(completionHandler: @escaping (Bool, String) -> Void) {
        if serverShouldBeUnavailable {
            completionHandler(false, .empty)
        } else {
            completionHandler(true, "Conexão com o servidor OK.")
        }
    }
    
    func getSoundShareCountStats(completionHandler: @escaping ([ServerShareCountStat]?, NetworkRabbitError?) -> Void) {
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

}
