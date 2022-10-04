import Combine
import UIKit

class MostSharedByAudienceViewViewModel: ObservableObject {

    @Published var audienceTop5: [TopChartItem]? = nil
    
    func reloadAudienceList() {
        var topCharts = [TopChartItem]()
        
        topCharts.append(TopChartItem(id: "1", contentId: "", contentName: "Teste", contentAuthorId: "", contentAuthorName: "Autor", shareCount: 10))
        
        DispatchQueue.main.async {
            self.audienceTop5 = topCharts
        }
    }

}
