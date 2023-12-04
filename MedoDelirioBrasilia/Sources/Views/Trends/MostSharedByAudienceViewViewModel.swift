//
//  MostSharedByAudienceViewViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 11/10/22.
//

import Foundation
import Combine

@MainActor
class MostSharedByAudienceViewViewModel: ObservableObject {

    @Published var last24HoursRanking: [TopChartItem]? = nil
    @Published var lastWeekRanking: [TopChartItem]? = nil
    @Published var lastMonthRanking: [TopChartItem]? = nil
    @Published var year2024Ranking: [TopChartItem]? = nil
    @Published var year2023Ranking: [TopChartItem]? = nil
    @Published var year2022Ranking: [TopChartItem]? = nil
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
        guard lastCheckDate.twoMinutesHavePassed else {
            return
        }
        lastCheckDate = .now
        lastUpdatedAtText = "Última consulta: agora mesmo"

        self.viewState = .loading
        
        Task {
            // Send user stats and retrieve remote stats
            let result = await Podium.shared.sendShareCountStatsToServer()

            guard result == .successful || result == .noStatsToSend else {
                await MainActor.run {
                    self.viewState = self.allTimeRanking == nil ? .noDataToDisplay : .displayingData
                    self.showServerUnavailableAlert()
                }
                return
            }

            do {
                self.last24HoursRanking = try await NetworkRabbit.shared.getSoundShareCountStats(for: .last24Hours)
                self.lastWeekRanking = try await NetworkRabbit.shared.getSoundShareCountStats(for: .lastWeek)

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

                case .year2024:
                    if self.year2024Ranking != nil, self.year2024Ranking?.isEmpty == false {
                        self.viewState = .displayingData
                    } else {
                        self.viewState = .noDataToDisplay
                    }

                case .year2023:
                    if self.year2023Ranking != nil, self.year2023Ranking?.isEmpty == false {
                        self.viewState = .displayingData
                    } else {
                        self.viewState = .noDataToDisplay
                    }

                case .year2022:
                    if self.year2022Ranking != nil, self.year2022Ranking?.isEmpty == false {
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
            } catch {
                print(error)
                showOtherServerErrorAlert(serverMessage: error.localizedDescription)
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

    private func showOtherServerErrorAlert(serverMessage: String) {
        TapticFeedback.error()
        alertTitle = "Não Foi Possível Obter os Dados Mais Recentes"
        alertMessage = serverMessage
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
        case .year2024:
            activityType = Shared.ActivityTypes.view2024TopChart
            activityName = "Ver sons mais compartilhados de 2024"
        case .year2023:
            activityType = Shared.ActivityTypes.view2023TopChart
            activityName = "Ver sons mais compartilhados de 2023"
        case .year2022:
            activityType = Shared.ActivityTypes.view2022TopChart
            activityName = "Ver sons mais compartilhados de 2022"
        case .allTime:
            activityType = Shared.ActivityTypes.viewAllTimeTopChart
            activityName = "Ver sons mais compartilhados de todos os tempos"
        }
        
        self.currentActivity = UserActivityWaiter.getDonatableActivity(withType: activityType, andTitle: activityName)
        self.currentActivity?.becomeCurrent()
    }
}
