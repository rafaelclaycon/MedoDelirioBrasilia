import SwiftUI

struct MostSharedByAudienceView: View {

    @StateObject private var viewModel = MostSharedByAudienceViewViewModel()
    @State private var timeIntervalOption = 2
    
    private let columns = [
        GridItem(.flexible())
    ]
    
    private var dropDownText: String {
        switch timeIntervalOption {
        case 1:
            return Shared.Trends.lastMonth
        case 2:
            return Shared.Trends.allTime
        default:
            return Shared.Trends.lastWeek
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
                    Picker("Período", selection: $timeIntervalOption) {
                        Text(Shared.Trends.lastWeek).tag(0)
                        Text(Shared.Trends.lastMonth).tag(1)
                        Text(Shared.Trends.allTime).tag(2)
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
                .onChange(of: timeIntervalOption) { timeIntervalOption in
                    if timeIntervalOption == 0 || timeIntervalOption == 1 {
                        viewModel.viewState = .noDataToDisplayForNow
                    } else {
                        if TimeKeeper.checkTwoMinutesHasPassed(viewModel.lastCheckDate) {
                            viewModel.reloadAudienceList()
                        } else {
                            if viewModel.audienceTop5 == nil {
                                viewModel.viewState = .noDataToDisplay
                            } else {
                                viewModel.viewState = .displayingData
                            }
                        }
                    }
                }
                
                Spacer()
                
                Button {
                    if timeIntervalOption == 2 {
                        viewModel.reloadAudienceList()
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("Atualizar")
                    }
                }
                .disabled(timeIntervalOption == 0 || timeIntervalOption == 1)
            }
            .padding(.horizontal)
            .padding(.top, 1)
            
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
                        
                        Text("Última consulta: hoje às 12:05")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                
            case .displayingData:
                VStack {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(viewModel.audienceTop5!) { item in
                            TopChartCellView(item: item)
                        }
                    }
                    .padding(.bottom)
                    
                    Text("Última consulta: hoje às 12:05")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 20)
                
            case .noDataToDisplayForNow:
                HStack {
                    Spacer()
                    
                    VStack(spacing: 10) {
                        Text("Sem Dados Por Enquanto")
                            .font(.headline)
                        
                        Text("Ainda não há dados coletados para essa visualização.")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 100)
                .padding(.horizontal)
            }
        }
    }

}

struct MostSharedByAudienceView_Previews: PreviewProvider {
    
    static var previews: some View {
        MostSharedByAudienceView()
    }
    
}
