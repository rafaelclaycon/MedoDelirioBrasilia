//
//  Podium.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 08/06/22.
//

import Foundation

class Podium {

    static let shared = Podium(database: LocalDatabase.shared, apiClient: APIClient.shared)

    private let database: LocalDatabaseProtocol
    private let apiClient: any APIClientProtocol

    init(
        database: LocalDatabaseProtocol,
        apiClient: some APIClientProtocol
    ) {
        self.database = database
        self.apiClient = apiClient
    }
    
    func top10SoundsSharedByTheUser() -> [TopChartItem]? {
        do {
            var items = try database.getTopSoundsSharedByTheUser(10)
            for i in 0..<items.count {
                items[i].id = UUID().uuidString
                items[i].rankNumber = "\(i + 1)"
            }
            return items
        } catch {
            print(error)
            return nil
        }
    }

    func sendShareCountStatsToServer() async -> ShareCountStatServerExchangeResult {
        guard await apiClient.serverIsAvailable() else { return .failed("Servidor indisponível.") }

        // Prepare local stats to be sent
        guard let stats = Logger.shared.shareCountStatsForServer() else {
            return .noStatsToSend
        }

        // Send them
        stats.forEach { stat in
            self.apiClient.post(shareCountStat: stat) { wasSuccessful, errorString in
                if wasSuccessful == false {
                    print("Sending of \(stat) failed: \(errorString)")
                }
            }
        }

        let bundleIdUrl = URL(string: apiClient.serverPath + "v1/shared-to-bundle-id")!

        // Send bundles IDs as well
        if let bundleIdLogs = Logger.shared.uniqueBundleIdsForServer() {
            for log in bundleIdLogs {
                do {
                    let _: ServerShareBundleIdLog = try await APIClient.shared.post(to: bundleIdUrl, body: log)
                } catch {
                    return .failed("Sending of \(log) failed.")
                }
            }
        }

        // Marking them as sent guarantees we won't send them again
        try? self.database.markAllUserShareLogsAsSentToServer()

        return .successful
    }
    
    func cleanAudienceSharingStatisticTableToReceiveUpdatedData() {
        try? self.database.clearAudienceSharingStatisticTable()
    }

    enum ShareCountStatServerExchangeResult: Equatable {

        case successful, noStatsToSend, failed(String)
    }
}
