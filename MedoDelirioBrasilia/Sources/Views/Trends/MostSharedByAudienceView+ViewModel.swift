//
//  MostSharedByAudienceViewViewModel.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 11/10/22.
//

import Foundation
import Combine

extension MostSharedByAudienceView {

    @MainActor
    final class ViewModel: ObservableObject {

        @Published var viewState: TrendsViewState = .noDataToDisplay
        @Published var ranking: [TopChartItem] = []
        @Published var lastCheckDate: Date = Date(timeIntervalSince1970: 0)
        @Published var timeIntervalOption: TrendsTimeInterval = .last24Hours
        @Published var lastUpdatedAtText: String = ""

        @Published var lastTimePulledDownToRefresh: Date = Date(timeIntervalSince1970: 0)

        @Published var currentActivity: NSUserActivity?

        // Alerts
        @Published var alertTitle: String = ""
        @Published var alertMessage: String = ""
        @Published var showAlert: Bool = false

        var displayToast: ((String) -> Void) = { _ in }

        func loadList(
            for timeInterval: TrendsTimeInterval,
            didPullDownToRefresh: Bool = false
        ) {
            // Check if enough time has passed for a retry
            if didPullDownToRefresh, !lastTimePulledDownToRefresh.twoMinutesHavePassed {
                displayToast(
                    "Aguarde \(lastTimePulledDownToRefresh.minutesAndSecondsFromNow) para atualizar novamente."
                )
                return
            }

            if didPullDownToRefresh {
                lastTimePulledDownToRefresh = .now
            }

            lastCheckDate = .now
            lastUpdatedAtText = "Última consulta: agora mesmo"

            self.viewState = .loading

            Task {
                // Send user stats and retrieve remote stats
                let result = await Podium.shared.sendShareCountStatsToServer()

                guard result == .successful || result == .noStatsToSend else {
                    await MainActor.run {
                        self.viewState = self.ranking.isEmpty ? .noDataToDisplay : .displayingData
                        self.showServerUnavailableAlert()
                    }
                    return
                }

                do {
                    self.ranking = try await NetworkRabbit.shared.getSoundShareCountStats(for: timeInterval).ranked
                    self.viewState = self.ranking.isEmpty ? .noDataToDisplay : .displayingData
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
            case .last3Days:
                activityType = Shared.ActivityTypes.viewLast24HoursTopChart
                activityName = "Ver sons mais compartilhados nos últimos 3 dias"
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
}
