import SwiftUI

struct TrendsView: View {

    @StateObject private var viewModel = TrendsViewViewModel()
    @State var showAlert = false
    @State var alertTitle = ""
    
    var showTrends: Bool {
        UserSettings.getEnableTrends()
    }
    
    var showMostSharedSoundsByTheUser: Bool {
        UserSettings.getEnableMostSharedSoundsByTheUser()
    }
    
    /*var showDayOfTheWeekTheUserSharesTheMost: Bool {
        UserSettings.getEnableDayOfTheWeekTheUserSharesTheMost()
    }*/
    
    var showSoundsMostSharedByTheAudience: Bool {
        UserSettings.getEnableSoundsMostSharedByTheAudience()
    }
    
    /*var showAppsThroughWhichTheUserSharesTheMost: Bool {
        UserSettings.getEnableAppsThroughWhichTheUserSharesTheMost()
    }*/
    
    var body: some View {
        VStack {
            if showTrends {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            if showMostSharedSoundsByTheUser {
                                MostSharedByMeView()
                                    .padding(.top, 10)
                            }
                            
                            /*if showDayOfTheWeekTheUserSharesTheMost {
                             Text("Dia da Semana No Qual Eu Mais Compartilho")
                             .font(.title2)
                             .padding(.horizontal)
                             }*/
                            
                            if showSoundsMostSharedByTheAudience {
                                MostSharedByAudienceView()
                                    .padding(.top, 10)
                            }
                            
                            /*if showAppsThroughWhichTheUserSharesTheMost {
                             Text("Apps Pelos Quais Você Mais Compartilha")
                             .font(.title2)
                             .padding(.horizontal)
                             }*/
                        }
                    }
                } else {
                    HStack {
                        if showMostSharedSoundsByTheUser {
                            MostSharedByMeView()
                        }
                        
                        if showSoundsMostSharedByTheAudience {
                            MostSharedByAudienceView()
                        }
                    }
                }
            } else {
                TrendsDisabledView()
                    .padding(.horizontal, 25)
            }
        }
        .navigationTitle("Tendências")
        .navigationBarTitleDisplayMode(showTrends ? .large : .inline)
        .onAppear {
            viewModel.donateActivity()
        }
    }

}

struct TrendsView_Previews: PreviewProvider {

    static var previews: some View {
        TrendsView()
    }

}
