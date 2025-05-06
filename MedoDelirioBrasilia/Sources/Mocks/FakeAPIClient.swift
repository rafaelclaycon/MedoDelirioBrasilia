//
//  FakeAPIClient.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 20/06/22.
//

import Foundation

class FakeAPIClient: APIClientProtocol {

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

    func getPixDonorNames() async -> [Donor]? {
        nil
    }

    func getReactionsStats() async throws -> [TopChartReaction] {
        []
    }

    func getShareCountStats(
        for contentType: TrendsContentType,
        in timeInterval: TrendsTimeInterval
    ) async throws -> [TopChartItem] {
        []
    }
}
