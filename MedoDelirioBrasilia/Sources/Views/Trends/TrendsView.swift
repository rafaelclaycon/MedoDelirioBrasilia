import SwiftUI

struct TrendsView: View {

    @StateObject private var viewModel = TrendsViewViewModel()
    @State private var mostSharedTimeIntervalOption = 0
    @State var showAlert = false
    @State var alertTitle = ""
    
    let columns = [
        GridItem(.flexible())
    ]
    
    var showTrends: Bool {
        UserSettings.getEnableTrends()
    }
    
    var showMostSharedSoundsByTheUser: Bool {
        UserSettings.getEnableMostSharedSoundsByTheUser()
    }
    
    var showDayOfTheWeekTheUserSharesTheMost: Bool {
        UserSettings.getEnableDayOfTheWeekTheUserSharesTheMost()
    }
    
    var showSoundsMostSharedByTheAudience: Bool {
        UserSettings.getEnableSoundsMostSharedByTheAudience()
    }
    
    var showAppsThroughWhichTheUserSharesTheMost: Bool {
        UserSettings.getEnableAppsThroughWhichTheUserSharesTheMost()
    }
    
    private var dropDownText: String {
        switch mostSharedTimeIntervalOption {
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
            if showTrends {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        if showMostSharedSoundsByTheUser {
                            Text("Sons Mais Compartilhados Por Mim")
                                .font(.title2)
                                .padding(.horizontal)
                                .padding(.top, 10)
                            
                            if viewModel.personalTop5 == nil {
                                HStack {
                                    Spacer()
                                    
                                    Text("Sem Dados")
                                        .font(.headline)
                                        .padding(.vertical, 40)
                                    
                                    Spacer()
                                }
                            } else {
                                VStack {
                                    HStack {
                                        Spacer()
                                        
                                        Button {
                                            viewModel.reloadPersonalList(withTopChartItems: podium.getTop5SoundsSharedByTheUser())
                                        } label: {
                                            HStack {
                                                Image(systemName: "arrow.triangle.2.circlepath")
                                                Text("Atualizar")
                                            }
                                        }
                                        .padding(.trailing)
                                        .padding(.top, 1)
                                        .padding(.bottom, 10)
                                    }
                                    
                                    LazyVGrid(columns: columns, spacing: 14) {
                                        ForEach(viewModel.personalTop5!) { item in
                                            TopChartCellView(item: item)
                                        }
                                    }
                                    .padding(.bottom)
                                    
                                    Text("Última consulta: hoje às 12:05")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                .padding(.bottom, 20)
                            }
                        }
                    }
                    
                    /*if showDayOfTheWeekTheUserSharesTheMost {
                        Text("Dia da Semana No Qual Eu Mais Compartilho")
                            .font(.title2)
                            .padding(.horizontal)
                    }*/
                    
                    if showSoundsMostSharedByTheAudience {
                        Text("Sons Mais Compartilhados Pela Audiência (iOS)")
                            .font(.title2)
                            .padding(.horizontal)
                            .padding(.top, 10)
                        
                        HStack {
                            Menu {
                                Picker("Período", selection: $mostSharedTimeIntervalOption) {
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
    //                        .onChange(of: viewModel.sortOption, perform: { newValue in
    //                            viewModel.reloadList(withSounds: soundData,
    //                                                 andFavorites: try? database.getAllFavorites(),
    //                                                 allowSensitiveContent: UserSettings.getShowOffensiveSounds(),
    //                                                 favoritesOnly: currentMode == .favorites,
    //                                                 sortedBy: SoundSortOption(rawValue: newValue) ?? .titleAscending)
    //                            UserSettings.setSoundSortOption(to: newValue)
    //                        })
                            
                            Spacer()
                            
                            Button {
                                viewModel.reloadAudienceList()
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                    Text("Atualizar")
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 1)
                        
                        if viewModel.audienceTop5 == nil {
                            HStack {
                                Spacer()
                                
                                VStack(spacing: 10) {
                                    Text("Sem Dados")
                                        .bold()
                                    
                                    Text("Última consulta: hoje às 12:05")
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 40)
                                
                                Spacer()
                            }
                        } else {
                            LazyVGrid(columns: columns, spacing: 14) {
                                ForEach(viewModel.audienceTop5!) { item in
                                    TopChartCellView(item: item)
                                }
                            }
                            .padding(.bottom)
                        }
                    }
                    
                    /*if showAppsThroughWhichTheUserSharesTheMost {
                        Text("Apps Pelos Quais Você Mais Compartilha")
                            .font(.title2)
                            .padding(.horizontal)
                    }*/
                }
            } else {
                TrendsDisabledView()
                    .padding(.horizontal, 25)
            }
        }
        .navigationTitle("Tendências")
        .navigationBarTitleDisplayMode(showTrends ? .large : .inline)
        .onAppear {
            viewModel.reloadPersonalList(withTopChartItems: podium.getTop5SoundsSharedByTheUser())
            viewModel.donateActivity()
        }
    }

}

struct TrendsView_Previews: PreviewProvider {

    static var previews: some View {
        TrendsView()
    }

}
