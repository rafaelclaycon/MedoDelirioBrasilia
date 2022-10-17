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
        var topCharts = [TopChartItem]()
        
        topCharts.append(TopChartItem(id: UUID().uuidString, rankNumber: "1", contentId: "", contentName: "Teste", contentAuthorId: "", contentAuthorName: "Autor", shareCount: 10))
        
        DispatchQueue.main.async {
            self.audienceTop5 = topCharts
        }
    }
    
    func donateActivity() {
        self.currentActivity = UserActivityWaiter.getDonatableActivity(withType: Shared.ActivityTypes.viewTrends, andTitle: "Ver Tendências")
        self.currentActivity?.becomeCurrent()
    }

}
