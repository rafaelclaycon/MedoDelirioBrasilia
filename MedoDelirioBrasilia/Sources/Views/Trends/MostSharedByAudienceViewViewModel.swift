import Combine
import UIKit

class MostSharedByAudienceViewViewModel: ObservableObject {

    @Published var lastWeekRanking: [TopChartItem]? = nil
    @Published var lastMonthRanking: [TopChartItem]? = nil
    @Published var allTimeRanking: [TopChartItem]? = nil
    
    @Published var viewState: TrendsViewState = .noDataToDisplay
    @Published var lastCheckDate: Date = Date(timeIntervalSince1970: 0)
    @Published var timeIntervalOption: TrendsTimeInterval = .lastWeek
    @Published var lastUpdatedAtText: String = .empty
    
    // Alerts
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    
    func reloadAudienceLists() {
        // Check if enough time has passed for a retry
        guard TimeKeeper.checkTwoMinutesHasPassed(lastCheckDate) || viewState == .noDataToDisplay else {
            return
        }
        lastCheckDate = .now
        lastUpdatedAtText = "Última consulta: agora mesmo"
        
        DispatchQueue.main.async {
            self.viewState = .loading
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {
                return
            }
            // Send user stats and retrieve remote stats
            podium.sendShareCountStatsToServer { result, _ in
                guard result == .successful || result == .noStatsToSend else {
                    if self.allTimeRanking == nil {
                        DispatchQueue.main.async {
                            self.viewState = .noDataToDisplay
                            self.showServerUnavailableAlert()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.viewState = .displayingData
                            self.showServerUnavailableAlert()
                        }
                    }
                    return
                }
                
                podium.cleanAudienceSharingStatisticTableToReceiveUpdatedData()
                
                podium.getAudienceShareCountStatsFromServer(for: .lastWeek) { result, _ in
                    guard result == .successful else {
                        return
                    }
                    DispatchQueue.main.async {
                        self.lastWeekRanking = podium.getTop10SoundsSharedByTheAudience(for: .lastWeek)
                    }
                }
                
                podium.getAudienceShareCountStatsFromServer(for: .lastMonth) { result, _ in
                    guard result == .successful else {
                        return
                    }
                    DispatchQueue.main.async {
                        self.lastMonthRanking = podium.getTop10SoundsSharedByTheAudience(for: .lastMonth)
                    }
                }
                
                podium.getAudienceShareCountStatsFromServer(for: .allTime) { result, _ in
                    guard result == .successful else {
                        return
                    }
                    DispatchQueue.main.async {
                        self.allTimeRanking = podium.getTop10SoundsSharedByTheAudience(for: .allTime)
                    }
                }
                
                // Delay needed so the lists actually have something in them.
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                    switch self.timeIntervalOption {
                    case .lastWeek:
                        if self.lastWeekRanking != nil, self.lastWeekRanking?.isEmpty == false {
                            self.viewState = .displayingData
                        } else {
                            self.viewState = .noDataToDisplay
                        }
                        
                    case .lastMonth:
                        if self.lastMonthRanking != nil, self.lastMonthRanking?.isEmpty == false {
                            self.viewState = .displayingData
                        } else {
                            self.viewState = .noDataToDisplay
                        }
                        
                    case .allTime:
                        if self.allTimeRanking != nil, self.allTimeRanking?.isEmpty == false {
                            self.viewState = .displayingData
                        } else {
                            self.viewState = .noDataToDisplay
                        }
                    }
                }
            }
        }
    }
    
    func updateLastUpdatedAtText() {
        if lastCheckDate == Date(timeIntervalSince1970: 0) {
            lastUpdatedAtText = "Última consulta: indisponível"
        } else {
            lastUpdatedAtText = "Última consulta: \(lastCheckDate.asRelativeDateTime)"
        }
    }
    
    private func showServerUnavailableAlert() {
        TapticFeedback.error()
        alertTitle = "Servidor Indisponível"
        alertMessage = "Não foi possível obter o ranking mais recente. Tente novamente mais tarde."
        showAlert = true
    }

}
