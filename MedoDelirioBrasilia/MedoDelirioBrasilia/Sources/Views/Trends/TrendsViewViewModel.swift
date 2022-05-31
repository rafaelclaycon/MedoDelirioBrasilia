import Combine
import UIKit

class TrendsViewViewModel: ObservableObject {

    @Published var topChartItems: [TopChartItem]? = nil
    
    @Published var currentActivity: NSUserActivity? = nil
    
    func reloadList(withTopChartItems topChartItems: [TopChartItem]?) {
        self.topChartItems = topChartItems
    }
    
    func donateActivity() {
        self.currentActivity = UserActivityWaiter.getDonatableActivity(withType: Shared.viewTrendsActivityTypeName, andTitle: "Ver Tendências")
        self.currentActivity?.becomeCurrent()
    }

}
