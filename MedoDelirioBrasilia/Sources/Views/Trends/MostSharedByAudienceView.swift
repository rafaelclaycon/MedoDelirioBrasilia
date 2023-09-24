//
//  MostSharedByAudienceView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 11/10/22.
//

import SwiftUI

struct MostSharedByAudienceView: View {

    @StateObject private var viewModel = MostSharedByAudienceViewViewModel()
    @Binding var tabSelection: PhoneTab
    @Binding var activePadScreen: PadScreen?
    @EnvironmentObject var trendsHelper: TrendsHelper

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
            return Shared.Trends.last24Hours
        case .lastWeek:
            return Shared.Trends.lastWeek
        case .lastMonth:
            return Shared.Trends.lastMonth
        case .allTime:
            return Shared.Trends.allTime
        }
    }

    private var list: [TopChartItem] {
        switch viewModel.timeIntervalOption {
        case .last24Hours:
            return viewModel.last24HoursRanking!
        case .lastWeek:
            return viewModel.lastWeekRanking!
        case .lastMonth:
            return viewModel.lastMonthRanking!
        case .allTime:
            return viewModel.allTimeRanking!
        }
    }

    var body: some View {
        VStack {
            HStack {
                Text("Sons Mais Compartilhados Pela Audiência (iOS)")
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
                    LazyVGrid(columns: UIDevice.isMac ? columnsMac : columns, spacing: .zero) {
                        ForEach(list) { item in
                            TopChartCellView(item: item)
                                .onTapGesture {
                                    navigateTo(sound: item.contentId)
                                }
                                .contextMenu {
                                    Button {
                                        navigateTo(sound: item.contentId)
                                    } label: {
                                        Label("Ir para Som", systemImage: "arrow.uturn.backward")
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
        .refreshable {
            Task {
                viewModel.reloadAudienceLists()
            }
        }
        .onAppear {
            viewModel.reloadAudienceLists()
            viewModel.donateActivity(forTimeInterval: viewModel.timeIntervalOption)
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    @ViewBuilder func timeIntervalSelector() -> some View {
        if UIDevice.isMac {
            Picker("Período", selection: $viewModel.timeIntervalOption) {
                Text(Shared.Trends.allTime).tag(TrendsTimeInterval.allTime)
                Text(Shared.Trends.lastMonth).tag(TrendsTimeInterval.lastMonth)
                Text(Shared.Trends.lastWeek).tag(TrendsTimeInterval.lastWeek)
                Text(Shared.Trends.last24Hours).tag(TrendsTimeInterval.last24Hours)
            }
            .pickerStyle(.segmented)
        } else {
            Menu {
                Picker("Período", selection: $viewModel.timeIntervalOption) {
                    Text(Shared.Trends.last24Hours).tag(TrendsTimeInterval.last24Hours)
                    Text(Shared.Trends.lastWeek).tag(TrendsTimeInterval.lastWeek)
                    Text(Shared.Trends.lastMonth).tag(TrendsTimeInterval.lastMonth)
                    Text(Shared.Trends.allTime).tag(TrendsTimeInterval.allTime)
                }
            } label: {
                HStack {
                    Text(dropDownText)
                    Image(systemName: "chevron.up.chevron.down")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15)
                }
            }
            .onChange(of: viewModel.timeIntervalOption) { timeIntervalOption in
                DispatchQueue.main.async {
                    switch viewModel.timeIntervalOption {
                    case .last24Hours:
                        if viewModel.last24HoursRanking == nil {
                            viewModel.viewState = .noDataToDisplay
                        } else {
                            viewModel.viewState = .displayingData
                        }
                        
                    case .lastWeek:
                        if viewModel.lastWeekRanking == nil {
                            viewModel.viewState = .noDataToDisplay
                        } else {
                            viewModel.viewState = .displayingData
                        }
                        
                    case .lastMonth:
                        if viewModel.lastMonthRanking == nil {
                            viewModel.viewState = .noDataToDisplay
                        } else {
                            viewModel.viewState = .displayingData
                        }
                        
                    case .allTime:
                        if viewModel.allTimeRanking == nil {
                            viewModel.viewState = .noDataToDisplay
                        } else {
                            viewModel.viewState = .displayingData
                        }
                    }
                }
                
                viewModel.donateActivity(forTimeInterval: timeIntervalOption)
            }
            .onReceive(trendsHelper.$timeIntervalToGoTo) { timeIntervalToGoTo in
                if let option = timeIntervalToGoTo {
                    DispatchQueue.main.async {
                        viewModel.timeIntervalOption = option
                    }
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
            tabSelection: .constant(.trends),
            activePadScreen: .constant(.trends)
        )
    }
}
