import SwiftUI

struct TrendsView: View {

    @StateObject private var viewModel = TrendsViewViewModel()
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
    
    var body: some View {
        NavigationView {
            VStack {
                if showTrends {
                    ScrollView {
                        VStack(alignment: .leading) {
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
                                    }
                                    
                                    LazyVGrid(columns: columns, spacing: 14) {
                                        ForEach(viewModel.personalTop5!) { item in
                                            TopChartCellView(item: item)
                                        }
                                    }
                                    .padding(.bottom)
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
                                    Spacer()
                                    
                                    Button {
                                        viewModel.reloadAudienceList()
                                    } label: {
                                        HStack {
                                            Image(systemName: "arrow.triangle.2.circlepath")
                                            Text("Atualizar")
                                        }
                                    }
                                    .padding(.trailing)
                                    .padding(.top, 1)
                                }
                                
                                if viewModel.audienceTop5 == nil {
                                    HStack {
                                        Spacer()
                                        
                                        Text("Sem Dados")
                                            .font(.headline)
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
                    }
                } else {
                    TrendsDisabledView()
                        .padding(.horizontal, 25)
                }
            }
            .navigationTitle("Tendências (Beta)")
            .navigationBarTitleDisplayMode(showTrends ? .large : .inline)
            .onAppear {
                viewModel.reloadPersonalList(withTopChartItems: podium.getTop5SoundsSharedByTheUser())
                viewModel.donateActivity()
            }
        }
    }

}

struct TrendsView_Previews: PreviewProvider {

    static var previews: some View {
        TrendsView()
    }

}
