//
//  TrendsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 29/05/22.
//

import SwiftUI

struct TrendsView: View {
    
    enum ViewMode: Int {
        case audience, me
    }
    
    @StateObject private var viewModel = TrendsViewViewModel()
    @Binding var tabSelection: PhoneTab
    @Binding var activePadScreen: PadScreen?
    @State var currentViewMode: ViewMode = .audience
    @State var showAlert = false
    @State var alertTitle = ""
    @EnvironmentObject var trendsHelper: TrendsHelper
    
    var showTrends: Bool {
        UserSettings.getEnableTrends()
    }
    
    /*var showMostSharedSoundsByTheUser: Bool {
        UserSettings.getEnableMostSharedSoundsByTheUser()
    }*/
    
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
                        Picker("Exibição", selection: $currentViewMode) {
                            Text("Da Audiência")
                                .tag(ViewMode.audience)
                            
                            Text("Minhas")
                                .tag(ViewMode.me)
                        }
                        .pickerStyle(.segmented)
                        .background(.regularMaterial)
                        .padding(.all)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            if showSoundsMostSharedByTheAudience {
                                MostSharedByAudienceView(tabSelection: $tabSelection,
                                                         activePadScreen: $activePadScreen)
                                    .environmentObject(trendsHelper)
                                    .padding(.top, 10)
                            }
                            
                            //if showMostSharedSoundsByTheUser {
                                MostSharedByMeView()
                                    .padding(.top, 10)
                            //}
                            
                            /*if showDayOfTheWeekTheUserSharesTheMost {
                             Text("Dia da Semana No Qual Eu Mais Compartilho")
                             .font(.title2)
                             .padding(.horizontal)
                             }*/
                            
                            /*if showAppsThroughWhichTheUserSharesTheMost {
                             Text("Apps Pelos Quais Você Mais Compartilha")
                             .font(.title2)
                             .padding(.horizontal)
                             }*/
                        }
                    }
                } else {
                    ScrollView {
                        HStack {
                            if showSoundsMostSharedByTheAudience {
                                VStack {
                                    MostSharedByAudienceView(tabSelection: $tabSelection,
                                                             activePadScreen: $activePadScreen)
                                    Spacer()
                                }
                                .padding(.top, 10)
                            }
                            
                            //if showMostSharedSoundsByTheUser {
                                VStack {
                                    MostSharedByMeView()
                                    Spacer()
                                }
                            //}
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
    }

}

struct TrendsView_Previews: PreviewProvider {

    static var previews: some View {
        TrendsView(tabSelection: .constant(.trends),
                   activePadScreen: .constant(.trends))
    }

}
