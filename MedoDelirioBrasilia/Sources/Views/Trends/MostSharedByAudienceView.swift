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
    @State private var shouldDisplayNewUpdateWayBanner: Bool = false
    @EnvironmentObject var trendsHelper: TrendsHelper
    @Environment(\.scenePhase) var scenePhase

    private let columns = [
        GridItem(.flexible())
    ]
    private let columnsMac = [
        GridItem(.fixed(500))
    ]
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    private var dropDownText: String {
        switch viewModel.timeIntervalOption {
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

    var body: some View {
        VStack {
            HStack {
                Text("Sons Mais Compartilhados Pela Audiência (iOS) 🏆")
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
                VStack {
                    if shouldDisplayNewUpdateWayBanner {
                        NewTrendsUpdateWayBannerView(
                            isBeingShown: $shouldDisplayNewUpdateWayBanner
                        )
                        .padding(.horizontal, 8)
                    }

                    LazyVGrid(columns: UIDevice.isMac ? columnsMac : columns, spacing: .zero) {
                        ForEach(viewModel.ranking) { item in
                            TopChartRow(item: item)
                                .onTapGesture {
                                    navigateTo(sound: item.contentId)
                                }
                                .contextMenu {
                                    if UIDevice.isiPhone {
                                        Button {
                                            navigateTo(sound: item.contentId)
                                        } label: {
                                            Label("Ir para Som", systemImage: "arrow.uturn.backward")
                                        }
                                    }
                                }
                        }
                    }
                    .padding(.top, -10)

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
            if viewModel.ranking.isEmpty {
                viewModel.loadList(for: viewModel.timeIntervalOption)
                viewModel.donateActivity(forTimeInterval: viewModel.timeIntervalOption)
            } else if viewModel.lastCheckDate.twoMinutesHavePassed {
                viewModel.loadList(for: viewModel.timeIntervalOption)
            }
            shouldDisplayNewUpdateWayBanner = !AppPersistentMemory().hasSeenNewTrendsUpdateWayBanner()
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active, viewModel.lastCheckDate.minutesPassed(60) {
                viewModel.loadList(for: viewModel.timeIntervalOption)
            }
        }
    }
    
    @ViewBuilder func timeIntervalSelector() -> some View {
        Menu {
            Picker("Período", selection: $viewModel.timeIntervalOption) {
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
        .onChange(of: viewModel.timeIntervalOption) {
            viewModel.loadList(for: $0)
            viewModel.donateActivity(forTimeInterval: $0)
        }
        .onReceive(trendsHelper.$timeIntervalToGoTo) { timeIntervalToGoTo in
            if let option = timeIntervalToGoTo {
                DispatchQueue.main.async {
                    viewModel.timeIntervalOption = option
                }
            }
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

struct MostSharedByAudienceView_Previews: PreviewProvider {
    static var previews: some View {
        MostSharedByAudienceView(
            viewModel: .init(),
            tabSelection: .constant(.trends),
            activePadScreen: .constant(.trends)
        )
    }
}
