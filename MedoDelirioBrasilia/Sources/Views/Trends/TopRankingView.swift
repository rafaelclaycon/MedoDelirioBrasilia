//
//  TopRankingView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 22/06/23.
//

import SwiftUI

struct TopRankingView: View {
    
    @Binding var tabSelection: PhoneTab
    @Binding var activePadScreen: PadScreen?
    
    @EnvironmentObject var trendsHelper: TrendsHelper
    
    let title: String
    let ranking: [TopChartItem]?
    let itemName: String
    
    @State private var viewState: TrendsViewState = .noDataToDisplay
    @State private var timeIntervalOption: TrendsTimeInterval = .last24Hours
    
    // Alerts
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    
    private let columns = [
        GridItem(.flexible())
    ]
    private let columnsMac = [
        GridItem(.fixed(500))
    ]
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    private var dropDownText: String {
        switch timeIntervalOption {
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
                
                Button {
                    //viewModel.reloadAudienceLists()
                } label: {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("Atualizar")
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 1)
            .padding(.bottom)
            
            switch viewState {
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
                        
//                        Text(viewModel.lastUpdatedAtText)
//                            .font(.subheadline)
//                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                
            case .displayingData:
                VStack {
//                    LazyVGrid(columns: UIDevice.isMac ? columnsMac : columns, spacing: 20) {
//                        ForEach(list) { item in
//                            TopChartCellView(item: item)
//                                .onTapGesture {
//                                    navigateTo(sound: item.contentId)
//                                }
//                                .contextMenu {
//                                    Button {
//                                        navigateTo(sound: item.contentId)
//                                    } label: {
//                                        Label("Ir para \(itemName)", systemImage: "arrow.uturn.backward")
//                                    }
//                                }
//                        }
//                    }
//                    .padding(.bottom)
                    
//                    Text(viewModel.lastUpdatedAtText)
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                        .onReceive(timer) { input in
//                            viewModel.updateLastUpdatedAtText()
//                        }
//                        .padding(.bottom)
                }
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            //viewModel.reloadAudienceLists()
            //viewModel.donateActivity(forTimeInterval: viewModel.timeIntervalOption)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    @ViewBuilder func timeIntervalSelector() -> some View {
        if UIDevice.isMac {
            Picker("Período", selection: $timeIntervalOption) {
                Text(Shared.Trends.allTime).tag(TrendsTimeInterval.allTime)
                Text(Shared.Trends.lastMonth).tag(TrendsTimeInterval.lastMonth)
                Text(Shared.Trends.lastWeek).tag(TrendsTimeInterval.lastWeek)
                Text(Shared.Trends.last24Hours).tag(TrendsTimeInterval.last24Hours)
            }
            .pickerStyle(.segmented)
        } else {
            Menu {
                Picker("Período", selection: $timeIntervalOption) {
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
//            .onChange(of: timeIntervalOption) { timeIntervalOption in
//                DispatchQueue.main.async {
//                    switch timeIntervalOption {
//                    case .last24Hours:
//                        if last24HoursRanking == nil {
//                            viewState = .noDataToDisplay
//                        } else {
//                            viewState = .displayingData
//                        }
//
//                    case .lastWeek:
//                        if lastWeekRanking == nil {
//                            viewState = .noDataToDisplay
//                        } else {
//                            viewState = .displayingData
//                        }
//
//                    case .lastMonth:
//                        if lastMonthRanking == nil {
//                            viewState = .noDataToDisplay
//                        } else {
//                            viewState = .displayingData
//                        }
//
//                    case .allTime:
//                        if allTimeRanking == nil {
//                            viewState = .noDataToDisplay
//                        } else {
//                            viewState = .displayingData
//                        }
//                    }
//                }
//
//                //viewModel.donateActivity(forTimeInterval: timeIntervalOption)
//            }
            .onReceive(trendsHelper.$timeIntervalToGoTo) { timeIntervalToGoTo in
                if let option = timeIntervalToGoTo {
                    DispatchQueue.main.async {
                        timeIntervalOption = option
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

struct TopRankingView_Previews: PreviewProvider {
    
    static var previews: some View {
        TopRankingView(tabSelection: .constant(.trends),
                       activePadScreen: .constant(.trends),
                       title: "Músicas Mais Compartilhadas Pela Audiência (iOS)",
                       ranking: nil,
                       itemName: "Música")
    }
}
