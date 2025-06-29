@testable import MedoDelirio
import Foundation

class FakeAPIClient: APIClientProtocol {

    var serverPath: String

    var serverShouldBeUnavailable = false
    var fetchUpdateEventsResult: ContentUpdateResult = .nothingToUpdate
    var retroStartingVersion: String?

    var updateEvents = [UpdateEvent]()

    var sound: Sound?
    var song: Song?
    var author: Author?
    var musicGenre: MusicGenre?

    init() {
        serverPath = ""
    }

    func get<T>(from url: URL) async throws -> T where T : Decodable, T : Encodable {
        return T.self as! T
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
            return updateEvents
        }
    }

    func retroStartingVersion() async -> String? {
        return retroStartingVersion
    }

    func post<T>(to url: URL, body: T) async throws where T : Encodable {
        //
    }

    func getString(from url: URL) async throws -> String? {
        nil
    }

    func displayAskForMoneyView(appVersion: String) async -> Bool {
        false
    }

    func getDonorNames() async -> [Donor]? {
        nil
    }

    func moneyInfo() async throws -> [MoneyInfo] {
        []
    }

    func sound(_ id: String) async throws -> Sound {
        sound!
    }

    func song(_ id: String) async throws -> Song {
        song!
    }

    func author(_ id: String) async throws -> Author {
        author!
    }

    func musicGenre(_ id: String) async throws -> MusicGenre {
        musicGenre!
    }
}
