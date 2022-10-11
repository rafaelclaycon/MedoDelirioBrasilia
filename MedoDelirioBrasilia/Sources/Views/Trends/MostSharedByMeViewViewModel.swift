import Combine
import UIKit

class MostSharedByMeViewViewModel: ObservableObject {

    @Published var personalTop5: [TopChartItem]? = nil
    
    func reloadPersonalList(withTopChartItems topChartItems: [TopChartItem]?) {
        self.personalTop5 = topChartItems
    }

}
