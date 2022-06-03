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
        
        
        //self.audienceTop5 =
    }
    
    func donateActivity() {
        self.currentActivity = UserActivityWaiter.getDonatableActivity(withType: Shared.viewTrendsActivityTypeName, andTitle: "Ver Tendências")
        self.currentActivity?.becomeCurrent()
    }

}
