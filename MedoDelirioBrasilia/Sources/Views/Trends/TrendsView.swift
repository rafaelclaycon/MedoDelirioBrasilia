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

    @EnvironmentObject var trendsHelper: TrendsHelper

    // Sounds of the Year
    @State private var isShowingBanner = false
    @State private var showModalView = false

    // Alert
    @State private var showAlert = false
    @State private var alertTitle = ""

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
                ScrollView {
                    Picker("Exibição", selection: $currentViewMode) {
                        Text("Da Audiência")
                            .tag(ViewMode.audience)

                        Text("Minhas")
                            .tag(ViewMode.me)
                    }
                    .pickerStyle(.segmented)
                    .padding(.all)

                    if currentViewMode == .audience {
                        VStack(alignment: .leading, spacing: 10) {
                            if showSoundsMostSharedByTheAudience {
                                MostSharedByAudienceView(
                                    tabSelection: $tabSelection,
                                    activePadScreen: $activePadScreen
                                )
                                .environmentObject(trendsHelper)
                            }
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 10) {
                            SoundsOfTheYearBanner(
                                isBeingShown: $isShowingBanner,
                                buttonAction: { showModalView = true }
                            )
                            .padding(.horizontal, 10)
                            .padding(.bottom)

                            //if showMostSharedSoundsByTheUser {
                                MostSharedByMeView()
                                    .environmentObject(trendsHelper)
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
                        .sheet(isPresented: $showModalView) {
                            SoundsOfTheYearGeneratorView(
                                viewModel: .init(),
                                isBeingShown: $showModalView
                            )
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
        TrendsView(
            tabSelection: .constant(.trends),
            activePadScreen: .constant(.trends)
        )
    }
}
