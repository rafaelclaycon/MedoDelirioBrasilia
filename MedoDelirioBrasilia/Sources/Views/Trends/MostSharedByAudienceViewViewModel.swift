import Combine
import UIKit

class MostSharedByAudienceViewViewModel: ObservableObject {

    @Published var audienceTop5: [TopChartItem]? = nil
    @Published var viewState: TrendsViewState = .noDataToDisplay
    @Published var lastCheckDate: Date = Date(timeIntervalSince1970: 0)
    @Published var timeIntervalOption: TrendsTimeInterval = .allTime
    
    func reloadAudienceList() {
        // Check if enough time has passed for a retry
        guard TimeKeeper.checkTwoMinutesHasPassed(lastCheckDate) else {
            return
        }
        lastCheckDate = .now
        
        DispatchQueue.main.async {
            self.viewState = .loading
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            // Send user stats and retrieve remote stats
            podium.sendShareCountStatsToServer { result, _ in
                guard result == .successful || result == .noStatsToSend else {
                    return
                }
                
                podium.getAudienceShareCountStatsFromServer(for: self?.timeIntervalOption ?? .allTime) { result, _ in
                    guard result == .successful else {
                        return
                    }
                    
                    DispatchQueue.main.async {
                        if let stats = podium.getTop10SoundsSharedByTheAudience(), stats.isEmpty == false {
                            self?.audienceTop5 = stats
                            self?.viewState = .displayingData
                        } else {
                            self?.viewState = .noDataToDisplay
                        }
                    }
                }
            }
        }
    }

}
