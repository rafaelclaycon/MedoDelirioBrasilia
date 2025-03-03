//
//  MostSharedByAudienceView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 11/10/22.
//

import SwiftUI

struct MostSharedByAudienceView: View {

    @ObservedObject var viewModel: ViewModel
    @Binding var tabSelection: PhoneTab
    @Binding var activePadScreen: PadScreen?
    @EnvironmentObject var trendsHelper: TrendsHelper
    @Environment(\.scenePhase) var scenePhase

    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            switch viewModel.viewState {
            case .loading:
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.3, anchor: .center)
                    
                    Text("CONTANDO CANALHICES")
                        .foregroundColor(.gray)
                        .font(.callout)
                }
                .padding(.vertical, 100)
                
            case .noDataToDisplay:
                HStack {
                    Spacer()
                    
                    VStack(spacing: 10) {
                        Text("Sem Dados")
                            .font(.headline)
                            .padding(.vertical, 40)
                        
                        Text(viewModel.lastUpdatedAtText)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                
            case .displayingData:
                VStack(spacing: 30) {
                    if viewModel.soundsState == .loading {
                        LoadingView()
                    } else {
                        LoadedRankingView(
                            title: "🔊 Sons Mais Compartilhados Pela Audiência",
                            items: viewModel.sounds,
                            timeIntervalOption: $viewModel.soundsTimeInterval,
                            navigateToAction: { soundId in
                                navigateTo(sound: soundId)
                            }
                        )
                        .onChange(of: viewModel.soundsTimeInterval) { newInterval in
                            Task {
                                await viewModel.onSoundsSelectedTimeIntervalChanged(newTimeInterval: newInterval)
                            }
                        }
                    }

                    if viewModel.songsState == .loading {
                        LoadingView()
                    } else {
                        LoadedRankingView(
                            title: "🎶 Músicas Mais Compartilhadas Pela Audiência",
                            items: viewModel.songs,
                            timeIntervalOption: $viewModel.songsTimeInterval,
                            navigateToAction: { _ in
                                //navigateTo(sound: soundId)
                            }
                        )
                        .onChange(of: viewModel.songsTimeInterval) { newInterval in
                            Task {
                                await viewModel.onSongsSelectedTimeIntervalChanged(newTimeInterval: newInterval)
                            }
                        }
                    }

                    Text("Os dados se referem apenas à audiência do app iOS.")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Text(viewModel.lastUpdatedAtText)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .onReceive(timer) { input in
                            viewModel.updateLastUpdatedAtText()
                        }
                        .padding(.bottom)
                }
                .padding(.bottom, 10)
            }
        }
        .onAppear {
            viewModel.onViewAppeared()
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
        }
        .onChange(of: scenePhase) { newPhase in
            viewModel.onScenePhaseChanged(isNewPhaseActive: newPhase == .active)
        }
    }

    private func navigateTo(sound soundId: String) {
        if UIDevice.current.userInterfaceIdiom == .phone {
            tabSelection = .sounds
        } else {
            activePadScreen = .allSounds
        }
        trendsHelper.soundIdToGoTo = soundId
    }
}

// MARK: - Subviews

extension MostSharedByAudienceView {

    struct LoadedRankingView: View {

        // MARK: - External Dependencies

        let title: String
        let items: [TopChartItem]
        @Binding var timeIntervalOption: TrendsTimeInterval
        let navigateToAction: (String) -> Void

        // MARK: - Private Properties

        private let columns = [GridItem(.flexible())]
        private let columnsMac = [GridItem(.fixed(500))]

        private var dropDownText: String {
            switch timeIntervalOption {
            case .last24Hours:
                Shared.Trends.last24Hours
            case .last3Days:
                Shared.Trends.last3Days
            case .lastWeek:
                Shared.Trends.lastWeek
            case .lastMonth:
                Shared.Trends.lastMonth
            case .year2024:
                Shared.Trends.year2024
            case .year2023:
                Shared.Trends.year2023
            case .year2022:
                Shared.Trends.year2022
            case .allTime:
                Shared.Trends.allTime
            }
        }

        // MARK: - View Body

        var body: some View {
            VStack {
                HStack {
                    Text(title)
                        .font(.title2)
                    Spacer()
                }
                .padding(.horizontal)

                HStack(spacing: 20) {
                    timeIntervalSelector()

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 1)
                .padding(.bottom)

                if items.isEmpty {
                    NoDataToDisplayView()
                } else {
                    LazyVGrid(columns: UIDevice.isMac ? columnsMac : columns, spacing: .zero) {
                        ForEach(items) { item in
                            TopChartRow(item: item)
                                .onTapGesture {
                                    navigateToAction(item.contentId)
                                }
                                .contextMenu {
                                    if UIDevice.isiPhone {
                                        Button {
                                            navigateToAction(item.contentId)
                                        } label: {
                                            Label("Ir para Som", systemImage: "arrow.uturn.backward")
                                        }
                                    }
                                }
                        }
                    }
                    .padding(.top, -10)
                }
            }
        }

        // MARK: - Subviews

        @ViewBuilder func timeIntervalSelector() -> some View {
            Menu {
                Picker("Período", selection: $timeIntervalOption) {
                    Text(Shared.Trends.last24Hours).tag(TrendsTimeInterval.last24Hours)
                    Text(Shared.Trends.last3Days).tag(TrendsTimeInterval.last3Days)
                    Text(Shared.Trends.lastWeek).tag(TrendsTimeInterval.lastWeek)
                    Text(Shared.Trends.lastMonth).tag(TrendsTimeInterval.lastMonth)
                    Text(Shared.Trends.year2024).tag(TrendsTimeInterval.year2024)
                    Text(Shared.Trends.year2023).tag(TrendsTimeInterval.year2023)
                    Text(Shared.Trends.year2022).tag(TrendsTimeInterval.year2022)
                    Text(Shared.Trends.allTime).tag(TrendsTimeInterval.allTime)
                }
            } label: {
                Label(dropDownText, systemImage: "chevron.up.chevron.down")
            }
//            .onReceive(trendsHelper.$timeIntervalToGoTo) { timeIntervalToGoTo in
//                if let option = timeIntervalToGoTo {
//                    DispatchQueue.main.async {
//                        viewModel.timeIntervalOption = option
//                    }
//                }
//            }
        }
    }

    struct NoDataToDisplayView: View {

        var body: some View {
            HStack {
                Spacer()

                VStack(spacing: 10) {
                    Text("Sem Dados para o Período Selecionado")
                        .font(.headline)
                        .padding(.vertical, 40)
                }

                Spacer()
            }
        }
    }

    struct LoadingView: View {

        var body: some View {
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.3, anchor: .center)

                Text("CONTANDO CANALHICES")
                    .foregroundColor(.gray)
                    .font(.callout)
            }
            .padding(.vertical, 100)
        }
    }
}

// MARK: - Preview

#Preview {
    MostSharedByAudienceView(
        viewModel: .init(),
        tabSelection: .constant(.trends),
        activePadScreen: .constant(.trends)
    )
}
