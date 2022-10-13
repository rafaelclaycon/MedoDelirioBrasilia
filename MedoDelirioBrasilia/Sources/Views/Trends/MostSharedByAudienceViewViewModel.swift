import Combine
import UIKit

class MostSharedByAudienceViewViewModel: ObservableObject {

    @Published var audienceTop5: [TopChartItem]? = nil
    @Published var viewState: TrendsViewState = .noDataToDisplay
    @Published var lastCheckDate: Date = Date(timeIntervalSince1970: 0)
    @Published var timeIntervalOption: TrendsTimeInterval = .allTime
    @Published var lastUpdatedAtText: String = .empty
    
    // Alerts
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    
    func reloadAudienceList() {
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
            // Send user stats and retrieve remote stats
            podium.sendShareCountStatsToServer { result, _ in
                guard result == .successful || result == .noStatsToSend else {
                    if self?.audienceTop5 == nil {
                        DispatchQueue.main.async {
                            self?.viewState = .noDataToDisplay
                            self?.showServerUnavailableAlert()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self?.viewState = .displayingData
                            self?.showServerUnavailableAlert()
                        }
                    }
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
