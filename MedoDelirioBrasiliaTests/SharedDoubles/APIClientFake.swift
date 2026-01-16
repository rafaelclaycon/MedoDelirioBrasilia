@testable import MedoDelirio
import Foundation

class FakeAPIClient: APIClientProtocol {

    var serverPath: String

    var serverShouldBeUnavailable = false
    var fetchUpdateEventsResult: SyncResult = .nothingToUpdate

    init() {
        serverPath = ""
    }

    func get<T>(from url: URL) async throws -> T where T : Decodable, T : Encodable {
        return T.self as! T
    }

    func getString(from url: URL) async throws -> String? {
        nil
    }

    func serverIsAvailable() async -> Bool {
        return !serverShouldBeUnavailable
    }

    func post(shareCountStat: ServerShareCountStat) async throws {
        //
    }

    func post(clientDeviceInfo: ClientDeviceInfo) async throws {
        //
    }

    func fetchUpdateEvents(from lastDate: String) async throws -> [MedoDelirio.UpdateEvent] {
        switch fetchUpdateEventsResult {
        default:
            return []
        }
    }

    func displayAskForMoneyView(appVersion: String) async -> Bool {
        false
    }

    func getDonorNames() async -> [Donor]? {
        nil
    }

    func moneyInfo() async throws -> [MoneyInfo] {
        return []
    }

    func post<T>(to url: URL, body: T) async throws where T : Encodable {
        //
    }
}
