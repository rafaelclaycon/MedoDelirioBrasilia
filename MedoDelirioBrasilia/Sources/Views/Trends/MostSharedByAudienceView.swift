import SwiftUI

struct MostSharedByAudienceView: View {

    @StateObject private var viewModel = MostSharedByAudienceViewViewModel()
    @Binding var tabSelection: PhoneTab
    @Binding var activePadScreen: PadScreen?
    @Binding var soundIdToGoToFromTrends: String
    
    private let columns = [
        GridItem(.flexible())
    ]
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    private var dropDownText: String {
        switch viewModel.timeIntervalOption {
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
            
            HStack {
                Menu {
                    Picker("Período", selection: $viewModel.timeIntervalOption) {
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
                    if TimeKeeper.checkTwoMinutesHasPassed(viewModel.lastCheckDate) {
                        viewModel.reloadAudienceLists()
                    } else {
                        if viewModel.allTimeRanking == nil {
                            viewModel.viewState = .noDataToDisplay
                        } else {
                            viewModel.viewState = .displayingData
                        }
                    }
                }
                
                Spacer()
                
                Button {
                    viewModel.reloadAudienceLists()
                } label: {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("Atualizar")
                    }
                }
                .disabled(viewModel.timeIntervalOption == .lastWeek || viewModel.timeIntervalOption == .lastMonth)
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
                    LazyVGrid(columns: columns, spacing: 20) {
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
                    .padding(.bottom)
                    
                    Text(viewModel.lastUpdatedAtText)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .onReceive(timer) { input in
                            viewModel.updateLastUpdatedAtText()
                        }
                        .padding(.bottom)
                }
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            viewModel.reloadAudienceLists()
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func navigateTo(sound soundId: String) {
        if UIDevice.current.userInterfaceIdiom == .phone {
            tabSelection = .sounds
        } else {
            activePadScreen = .allSounds
        }
        soundIdToGoToFromTrends = soundId
    }

}

struct MostSharedByAudienceView_Previews: PreviewProvider {

    static var previews: some View {
        MostSharedByAudienceView(tabSelection: .constant(.trends), activePadScreen: .constant(.trends), soundIdToGoToFromTrends: .constant(.empty))
    }

}
