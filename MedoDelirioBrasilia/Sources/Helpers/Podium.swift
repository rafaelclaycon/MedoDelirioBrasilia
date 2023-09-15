import Foundation

class Podium {

    private var database: LocalDatabase
    private var networkRabbit: NetworkRabbitProtocol
    
    init(database injectedDatabase: LocalDatabase, networkRabbit injectedNetwork: NetworkRabbitProtocol) {
        self.database = injectedDatabase
        self.networkRabbit = injectedNetwork
    }
    
    func getTop5SoundsSharedByTheUser() -> [TopChartItem]? {
        var result = [TopChartItem]()
        var filteredSounds: [Sound]
        var filteredAuthors: [Author]
        var itemInPreparation: TopChartItem
        
        guard let dimItems = try? database.getTop5SoundsSharedByTheUser(), dimItems.count > 0 else {
            return nil
        }
        
        for i in 0...(dimItems.count - 1) {
            // TODO: - Fix this
            filteredSounds = [] // soundData.filter({ $0.id == dimItems[i].contentId })
            
            guard filteredSounds.count > 0 else {
                continue
            }
            
            guard let allAuthors = try? database.allAuthors() else { return nil }
            filteredAuthors = allAuthors.filter({ $0.id == filteredSounds[0].authorId })
            
            guard filteredAuthors.count > 0 else {
                continue
            }
            
            itemInPreparation = TopChartItem(id: UUID().uuidString, rankNumber: "\(i + 1)", contentId: dimItems[i].contentId, contentName: filteredSounds[0].title, contentAuthorId: filteredSounds[0].authorId, contentAuthorName: filteredAuthors[0].name, shareCount: dimItems[i].shareCount)
            
            result.append(itemInPreparation)
        }
        
        if result.count > 0 {
            return result
        } else {
            return nil
        }
    }
    
    func getTop10SoundsSharedByTheAudience(for timeInterval: TrendsTimeInterval) -> [TopChartItem]? {
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
    
    func sendShareCountStatsToServer(completionHandler: @escaping (ShareCountStatServerExchangeResult, String) -> Void) {
        networkRabbit.checkServerStatus { serverIsAvailable in
            guard serverIsAvailable else {
                return completionHandler(.failed, "Servidor não disponível.")
            }
            
            // Prepare local stats to be sent
            guard let stats = Logger.shared.getShareCountStatsForServer() else {
                return completionHandler(.noStatsToSend, "No stats to be sent.")
            }
            
            // Send them
            stats.forEach { stat in
                self.networkRabbit.post(shareCountStat: stat) { wasSuccessful, errorString in
                    if wasSuccessful == false {
                        print("Sending of \(stat) failed: \(errorString)")
                    }
                }
            }
            
            // Send bundles IDs as well
            if let bundleIdLogs = Logger.shared.getUniqueBundleIdsForServer() {
                bundleIdLogs.forEach { log in
                    self.networkRabbit.post(bundleIdLog: log) { wasSuccessful, _ in
                        guard wasSuccessful else {
                            return completionHandler(.failed, "Sending of \(log) failed.")
                        }
                    }
                }
            }
            
            // Marking them as sent guarantees we won't send them again
            try? self.database.markAllUserShareLogsAsSentToServer()
            
            completionHandler(.successful, "")
        }
    }
    
    func cleanAudienceSharingStatisticTableToReceiveUpdatedData() {
        try? self.database.clearAudienceSharingStatisticTable()
    }
    
    func getAudienceShareCountStatsFromServer(for timeInterval: TrendsTimeInterval, completionHandler: @escaping (ShareCountStatServerExchangeResult, String) -> Void) {
        self.networkRabbit.getSoundShareCountStats(timeInterval: timeInterval) { stats, error in
            guard error == nil else {
                return completionHandler(.failed, "")
            }
            guard let stats = stats, stats.isEmpty == false else {
                return
            }
            
            // Save them
            var audienceStat: AudienceShareCountStat? = nil
            stats.forEach { stat in
                audienceStat = AudienceShareCountStat(contentId: stat.contentId, contentType: stat.contentType, shareCount: stat.shareCount, rankingType: timeInterval.rawValue)
                try? self.database.insert(audienceStat: audienceStat!)
            }
            
            // Let the caller now
            completionHandler(.successful, .empty)
        }
    }
    
    enum ShareCountStatServerExchangeResult {
        
        case successful, noStatsToSend, failed
    }
}
