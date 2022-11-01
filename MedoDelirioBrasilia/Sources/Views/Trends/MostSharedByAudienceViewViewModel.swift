//
//  MostSharedByAudienceViewViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 11/10/22.
//

import Combine
import UIKit

class MostSharedByAudienceViewViewModel: ObservableObject {

    @Published var last24HoursRanking: [TopChartItem]? = nil
    @Published var lastWeekRanking: [TopChartItem]? = nil
    @Published var lastMonthRanking: [TopChartItem]? = nil
    @Published var allTimeRanking: [TopChartItem]? = nil
    
    @Published var viewState: TrendsViewState = .noDataToDisplay
    @Published var lastCheckDate: Date = Date(timeIntervalSince1970: 0)
    @Published var timeIntervalOption: TrendsTimeInterval = .last24Hours
    @Published var lastUpdatedAtText: String = .empty
    
    @Published var currentActivity: NSUserActivity? = nil
    
    // Alerts
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    
    func reloadAudienceLists() {
        // Check if enough time has passed for a retry
        guard TimeKeeper.checkTwoMinutesHasPassed(lastCheckDate) else {
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
                
                podium.getAudienceShareCountStatsFromServer(for: .last24Hours) { result, _ in
                    guard result == .successful else {
                        return
                    }
                    DispatchQueue.main.async {
                        self.last24HoursRanking = podium.getTop10SoundsSharedByTheAudience(for: .last24Hours)
                    }
                }
                
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
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                    switch self.timeIntervalOption {
                    case .last24Hours:
                        if self.last24HoursRanking != nil, self.last24HoursRanking?.isEmpty == false {
                            self.viewState = .displayingData
                        } else {
                            self.viewState = .noDataToDisplay
                        }
                        
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
    
    func donateActivity(forTimeInterval timeIntervalOption: TrendsTimeInterval) {
        var activityType = ""
        var activityName = ""
        
        switch timeIntervalOption {
        case .last24Hours:
            activityType = Shared.ActivityTypes.viewLast24HoursTopChart
            activityName = "Ver sons mais compartilhados nas últimas 24 horas"
        case .lastWeek:
            activityType = Shared.ActivityTypes.viewLastWeekTopChart
            activityName = "Ver sons mais compartilhados na última semana"
        case .lastMonth:
            activityType = Shared.ActivityTypes.viewLastMonthTopChart
            activityName = "Ver sons mais compartilhados no último mês"
        case .allTime:
            activityType = Shared.ActivityTypes.viewAllTimeTopChart
            activityName = "Ver sons mais compartilhados de todos os tempos"
        }
        
        self.currentActivity = UserActivityWaiter.getDonatableActivity(withType: activityType, andTitle: activityName)
        self.currentActivity?.becomeCurrent()
    }

}
