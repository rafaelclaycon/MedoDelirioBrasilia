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
            filteredSounds = soundData.filter({ $0.id == dimItems[i].contentId })
            
            guard filteredSounds.count > 0 else {
                continue
            }
            
            filteredAuthors = authorData.filter({ $0.id == filteredSounds[0].authorId })
            
            guard filteredAuthors.count > 0 else {
                continue
            }
            
            itemInPreparation = TopChartItem(id: "\(i + 1)", contentId: dimItems[i].contentId, contentName: filteredSounds[0].title, contentAuthorId: filteredSounds[0].authorId, contentAuthorName: filteredAuthors[0].name, shareCount: dimItems[i].shareCount)
            
            result.append(itemInPreparation)
        }
        
        if result.count > 0 {
            return result
        } else {
            return nil
        }
    }
    
    func getTop5SoundsSharedByTheAudience() -> [TopChartItem]? {
        var result = [TopChartItem]()
        var filteredSounds: [Sound]
        var filteredAuthors: [Author]
        var itemInPreparation: TopChartItem
        
        guard let dimItems = try? database.getTop5SoundsSharedByTheAudience(), dimItems.count > 0 else {
            return nil
        }
        
        for i in 0...(dimItems.count - 1) {
            filteredSounds = soundData.filter({ $0.id == dimItems[i].contentId })
            
            guard filteredSounds.count > 0 else {
                continue
            }
            
            filteredAuthors = authorData.filter({ $0.id == filteredSounds[0].authorId })
            
            guard filteredAuthors.count > 0 else {
                continue
            }
            
            itemInPreparation = TopChartItem(id: "\(i + 1)", contentId: dimItems[i].contentId, contentName: filteredSounds[0].title, contentAuthorId: filteredSounds[0].authorId, contentAuthorName: filteredAuthors[0].name, shareCount: dimItems[i].shareCount)
            
            result.append(itemInPreparation)
        }
        
        if result.count > 0 {
            return result
        } else {
            return nil
        }
    }
    
    func exchangeShareCountStatsWithTheServer(completionHandler: @escaping (Bool, String) -> Void) {
        networkRabbit.checkServerStatus { serverIsAvailable, _ in
            guard serverIsAvailable else {
                return completionHandler(false, "Servidor não disponível.")
            }
            
            // Prepare local stats to be sent
            //let stat = ServerShareCountStat(installId: <#T##String#>, contentId: <#T##String#>, contentType: <#T##Int#>, shareCount: <#T##Int#>)
            
            // Send them
            //networkRabbit.post(shareCountStat: , completionHandler: <#T##(String) -> Void#>)
            
            // Get remote stats
            self.networkRabbit.getSoundShareCountStats { stats, error in
                guard error == nil else {
                    return
                }
                guard let stats = stats else {
                    return
                }
                // Save them
                var audienceStat: AudienceShareCountStat? = nil
                stats.forEach { stat in
                    audienceStat = AudienceShareCountStat(contentId: stat.contentId, contentType: stat.contentType, shareCount: stat.shareCount)
                    try? self.database.insert(audienceStat: audienceStat!)
                }
                
                // Let the caller now 
                //self.audienceTop5 = Podium.getTop5SoundsSharedByTheAudience()
            }
        }
    }

}
