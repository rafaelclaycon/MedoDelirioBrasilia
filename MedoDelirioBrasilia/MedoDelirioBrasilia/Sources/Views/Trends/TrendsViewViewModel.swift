import Combine
import UIKit

class TrendsViewViewModel: ObservableObject {

    @Published var topChartItems: [TopChartItem]? = nil
    
    func reloadList(withTopChartItems topChartItems: [TopChartItem]?) {
        self.topChartItems = topChartItems
    }

}
