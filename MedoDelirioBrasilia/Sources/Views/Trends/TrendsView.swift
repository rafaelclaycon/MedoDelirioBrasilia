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

    @StateObject private var viewModel = ViewModel()
    @State private var audienceViewModel = MostSharedByAudienceView.ViewModel()

    @Binding var tabSelection: PhoneTab
    @Binding var activePadScreen: PadScreen?
    @State var currentViewMode: ViewMode = .audience

    @EnvironmentObject var trendsHelper: TrendsHelper

    // Alert
    @State private var showAlert = false
    @State private var alertTitle = ""

    var showTrends: Bool {
        UserSettings().getEnableTrends()
    }

    /*var showMostSharedSoundsByTheUser: Bool {
        UserSettings().getEnableMostSharedSoundsByTheUser()
    }*/

    /*var showDayOfTheWeekTheUserSharesTheMost: Bool {
        UserSettings().getEnableDayOfTheWeekTheUserSharesTheMost()
    }*/

    var showSoundsMostSharedByTheAudience: Bool {
        UserSettings().getEnableSoundsMostSharedByTheAudience()
    }

    /*var showAppsThroughWhichTheUserSharesTheMost: Bool {
        UserSettings().getEnableAppsThroughWhichTheUserSharesTheMost()
    }*/

    var body: some View {
        VStack {
            if showTrends {
                ScrollView {
                    Picker("Exibição", selection: $currentViewMode) {
                        Text("🏆  Da Audiência")
                            .tag(ViewMode.audience)

                        Text("🧑  Pessoais")
                            .tag(ViewMode.me)
                    }
                    .pickerStyle(.segmented)
                    .padding(.all)

                    if currentViewMode == .audience {
                        VStack(alignment: .leading, spacing: 10) {
                            if showSoundsMostSharedByTheAudience {
                                MostSharedByAudienceView(
                                    viewModel: audienceViewModel,
                                    tabSelection: $tabSelection,
                                    activePadScreen: $activePadScreen
                                )
                                .environmentObject(trendsHelper)
                            }
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 10) {
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
                    }
                }
                .if(currentViewMode == .audience) {
                    $0.refreshable {
                        await audienceViewModel.onPullToRefreshLists()
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
            audienceViewModel.displayToast = { message in
                viewModel.displayToast(
                    "clock.fill",
                    .orange,
                    toastText: message,
                    displayTime: .seconds(3)
                )
            }

            Analytics().send(
                originatingScreen: "TrendsView",
                action: "didViewTrendsTab"
            )
        }
        .overlay {
            if viewModel.showToastView {
                VStack {
                    Spacer()

                    ToastView(
                        icon: viewModel.toastIcon,
                        iconColor: viewModel.toastIconColor,
                        text: viewModel.toastText
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 15)
                }
                .transition(.moveAndFade)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    TrendsView(
        tabSelection: .constant(.trends),
        activePadScreen: .constant(.trends)
    )
}
