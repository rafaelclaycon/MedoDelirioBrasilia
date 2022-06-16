import Combine
import UIKit

class TrendsViewViewModel: ObservableObject {

    @Published var personalTop5: [TopChartItem]? = nil
    @Published var audienceTop5: [TopChartItem]? = nil
    
    @Published var currentActivity: NSUserActivity? = nil
    
    func reloadPersonalList(withTopChartItems topChartItems: [TopChartItem]?) {
        self.personalTop5 = topChartItems
    }
    
    func reloadAudienceList() {
        networkRabbit.checkServerStatus { serverIsAvailable, _ in
            guard serverIsAvailable else {
                return
            }
            
            networkRabbit.getSoundShareCountStats { stats, error in
                guard error == nil else {
                    return
                }
                guard let stats = stats else {
                    return
                }
                var audienceStat: AudienceShareCountStat? = nil
                stats.forEach { stat in
                    audienceStat = AudienceShareCountStat(contentId: stat.contentId, contentType: stat.contentType, shareCount: stat.shareCount)
                    try? database.insert(audienceStat: audienceStat!)
                }
                
                DispatchQueue.main.async {
                    self.audienceTop5 = Podium.getTop5SoundsSharedByTheAudience()
                }
            }
        }
    }
    
    func donateActivity() {
        self.currentActivity = UserActivityWaiter.getDonatableActivity(withType: Shared.viewTrendsActivityTypeName, andTitle: "Ver Tendências")
        self.currentActivity?.becomeCurrent()
    }

}
