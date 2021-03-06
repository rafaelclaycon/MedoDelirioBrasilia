import SwiftUI

struct TrendsView: View {

    @StateObject private var viewModel = TrendsViewViewModel()
    @State private var favoriteColor = 0
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
                                    }
                                    
                                    LazyVGrid(columns: columns, spacing: 14) {
                                        ForEach(viewModel.personalTop5!) { item in
                                            TopChartCellView(item: item)
                                        }
                                    }
                                    .padding(.bottom)
                                    
                                    Text("??ltima consulta: hoje ??s 12:05")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                .padding(.bottom, 20)
                            }
                        }
                        
                        /*if showDayOfTheWeekTheUserSharesTheMost {
                            Text("Dia da Semana No Qual Eu Mais Compartilho")
                                .font(.title2)
                                .padding(.horizontal)
                        }*/
                        
                        if showSoundsMostSharedByTheAudience {
                            Text("Sons Mais Compartilhados Pela Audi??ncia (iOS)")
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
                            
                            Picker("What is your favorite color?", selection: $favoriteColor) {
                                Text("Semana").tag(0)
                                Text("M??s").tag(1)
                                Text("Todos os Tempos").tag(2)
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal)
                            
                            if viewModel.audienceTop5 == nil {
                                HStack {
                                    Spacer()
                                    
                                    VStack(spacing: 10) {
                                        Text("Sem Dados")
                                            //.font(.headline)
                                            .bold()
                                        
                                        Text("??ltima consulta: hoje ??s 12:05")
                                            //.font(.subheadline)
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
                            Text("Apps Pelos Quais Voc?? Mais Compartilha")
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
        .navigationTitle("Tend??ncias (Beta)")
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
