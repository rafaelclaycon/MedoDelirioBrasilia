import Combine
import UIKit

class MostSharedByAudienceViewViewModel: ObservableObject {

    @Published var audienceTop5: [TopChartItem]? = nil
    @Published var viewState: TrendsViewState = .noDataToDisplay
    
    func reloadAudienceList() {
        DispatchQueue.main.async {
            self.viewState = .loading
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            // Check if enough time has passed for a retry
            
            // Send user stats
            
            // Retrieve remote stats
            
            networkRabbit.getSoundShareCountStats { stats, error in
                guard error == nil else {
                    return
                }
                guard let stats = stats, stats.isEmpty == false else {
                    return
                }
                
            }
        }
        
        var topCharts = [TopChartItem]()
        
        topCharts.append(TopChartItem(id: "1", contentId: "", contentName: "Teste", contentAuthorId: "", contentAuthorName: "Autor", shareCount: 10))
        
        DispatchQueue.main.async {
            self.audienceTop5 = topCharts
        }
    }

}
