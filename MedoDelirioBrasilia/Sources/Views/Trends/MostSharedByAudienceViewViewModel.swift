import Combine
import UIKit

class MostSharedByAudienceViewViewModel: ObservableObject {

    @Published var audienceTop5: [TopChartItem]? = nil
    @Published var viewState: TrendsViewState = .noDataToDisplay
    @Published var lastCheckDate: Date = Date(timeIntervalSince1970: 0)
    
    func reloadAudienceList() {
        DispatchQueue.main.async {
            self.viewState = .loading
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            // Check if enough time has passed for a retry
            guard TimeKeeper.checkTwoMinutesHasPassed(self?.lastCheckDate ?? Date.now) else {
                return
            }
            
            // Send user stats and retrieve remote stats
            podium.exchangeShareCountStatsWithTheServer { result, _ in
                guard result == .successful || result == .noStatsToSend else {
                    return
                }
                print(result)
            }
        }
        
        var topCharts = [TopChartItem]()
        
        topCharts.append(TopChartItem(id: "1", contentId: "", contentName: "Teste", contentAuthorId: "", contentAuthorName: "Autor", shareCount: 10))
        
        DispatchQueue.main.async {
            self.audienceTop5 = topCharts
        }
    }

}
