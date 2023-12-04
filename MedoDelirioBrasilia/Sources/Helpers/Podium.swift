import Foundation

class Podium {

    static let shared = Podium(database: LocalDatabase.shared, networkRabbit: NetworkRabbit.shared)

    private let database: LocalDatabase
    private let networkRabbit: any NetworkRabbitProtocol

    init(
        database injectedDatabase: LocalDatabase,
        networkRabbit injectedNetwork: some NetworkRabbitProtocol
    ) {
        self.database = injectedDatabase
        self.networkRabbit = injectedNetwork
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
    
    func top10SoundsSharedByTheAudience(for timeInterval: TrendsTimeInterval) -> [TopChartItem]? {
        do {
            var items = try database.getTop10SoundsSharedByTheAudience(for: timeInterval)
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
        guard await networkRabbit.serverIsAvailable() else { return .failed("Servidor indisponível.") }

        // Prepare local stats to be sent
        guard let stats = Logger.shared.getShareCountStatsForServer() else {
            return .noStatsToSend
        }

        // Send them
        stats.forEach { stat in
            self.networkRabbit.post(shareCountStat: stat) { wasSuccessful, errorString in
                if wasSuccessful == false {
                    print("Sending of \(stat) failed: \(errorString)")
                }
            }
        }

        let bundleIdUrl = URL(string: networkRabbit.serverPath + "v1/shared-to-bundle-id")!

        // Send bundles IDs as well
        if let bundleIdLogs = Logger.shared.getUniqueBundleIdsForServer() {
            for log in bundleIdLogs {
                do {
                    let _: ServerShareBundleIdLog = try await NetworkRabbit.post(to: bundleIdUrl, body: log)
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
