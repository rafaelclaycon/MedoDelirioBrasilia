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
        
        @Published var soundsState: LoadingState<[TopChartItem]> = .loading
        @Published var soundsTimeInterval: TrendsTimeInterval = .last24Hours
        @Published var soundsLastCheckDate: Date = Date(timeIntervalSince1970: 0)
        
        @Published var songsState: LoadingState<[TopChartItem]> = .loading
        @Published var songsTimeInterval: TrendsTimeInterval = .allTime
        @Published var songsLastCheckDate: Date = Date(timeIntervalSince1970: 0)
        
        @Published var lastTimePulledDownToRefresh: Date = Date(timeIntervalSince1970: 0)
        
        @Published var currentActivity: NSUserActivity?
        
        // Alerts
        @Published var alertTitle: String = ""
        @Published var alertMessage: String = ""
        @Published var showAlert: Bool = false
        
        var displayToast: ((String) -> Void) = { _ in }
    }
}

// MARK: - Internal Functions

extension MostSharedByAudienceView.ViewModel {

    private func loadAll(
        didPullDownToRefresh: Bool = false
    ) async {
        // Check if enough time has passed for a retry
        if didPullDownToRefresh, !lastTimePulledDownToRefresh.minutesPassed(1) {
            displayToast(
                String(format: Shared.Sync.waitMessage, lastTimePulledDownToRefresh.minutesAndSecondsFromNow)
            )
            return
        }

        if didPullDownToRefresh {
            lastTimePulledDownToRefresh = .now
        }

        // Send user stats and retrieve remote stats
        let result = await Podium.shared.sendShareCountStatsToServer()

        guard result == .successful || result == .noStatsToSend else {
            await MainActor.run {
                self.soundsState = .error("")
                self.songsState = .error("")
                self.showServerUnavailableAlert()
            }
            return
        }

        do {
            await loadSoundsList()
            await loadSongsList()
        } catch {
            print(error)
            showOtherServerErrorAlert(serverMessage: error.localizedDescription)
        }
    }

    private func loadSoundsList() async {
        soundsState = .loading
        do {
            let soundRanking = try await NetworkRabbit.shared.getShareCountStats(
                for: .sounds,
                in: soundsTimeInterval
            ).ranked

            soundsState = .loaded(soundRanking)
        } catch {
            print(error)
            showOtherServerErrorAlert(serverMessage: error.localizedDescription)
        }
    }

    private func loadSongsList() async {
        songsState = .loading
        do {
            let songRanking = try await NetworkRabbit.shared.getShareCountStats(
                for: .songs,
                in: songsTimeInterval
            ).ranked

            songsState = .loaded(songRanking)
        } catch {
            print(error)
            showOtherServerErrorAlert(serverMessage: error.localizedDescription)
        }
    }

    func updateLastUpdatedAtText() {

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

    private func donateActivity(forTimeInterval timeIntervalOption: TrendsTimeInterval) {
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

// MARK: - User Actions

extension MostSharedByAudienceView.ViewModel {

    public func onViewAppeared() async {
        if soundsState == .loading {
            await loadAll()
            donateActivity(forTimeInterval: soundsTimeInterval)
        } else if soundsLastCheckDate.minutesPassed(1) {
            await loadAll()
        }
    }

    public func onScenePhaseChanged(isNewPhaseActive: Bool) async {
        if isNewPhaseActive, soundsLastCheckDate.minutesPassed(60) {
            await loadAll()
        }
    }

    public func onSoundsSelectedTimeIntervalChanged(newTimeInterval: TrendsTimeInterval) async {
        await loadSoundsList()
        donateActivity(forTimeInterval: newTimeInterval)
    }

    public func onSongsSelectedTimeIntervalChanged(newTimeInterval: TrendsTimeInterval) async {
        await loadSongsList()
        //donateActivity(forTimeInterval: newTimeInterval) // TODO: Adapt for Songs.
    }

    public func onPullToRefreshLists() async {
        await loadAll(didPullDownToRefresh: true)
    }
}
