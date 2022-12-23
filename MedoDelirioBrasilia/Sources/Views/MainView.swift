//
//  MainView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 19/05/22.
//

import SwiftUI

struct MainView: View {

    @State var tabSelection: PhoneTab = .sounds
    @State var state: PadScreen? = PadScreen.allSounds
    @State var isShowingSettingsSheet: Bool = false
    @StateObject var settingsHelper = SettingsHelper()
    @State var isShowingFolderInfoEditingSheet: Bool = false
    @State var updateFolderList: Bool = false
    
    // Trends
    @State var soundIdToGoToFromTrends: String = .empty
    @StateObject var trendsHelper = TrendsHelper()
    
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            TabView(selection: $tabSelection) {
                NavigationView {
                    SoundsView(viewModel: SoundsViewViewModel(soundSortOption: UserSettings.getSoundSortOption(),
                                                              authorSortOption: AuthorSortOption.nameAscending.rawValue),
                               currentMode: .allSounds)
                        .environmentObject(trendsHelper)
                        .environmentObject(settingsHelper)
                }
                .tabItem {
                    Label("Sons", systemImage: "speaker.wave.3.fill")
                }
                .tag(PhoneTab.sounds)
                
//                NavigationView {
//                    CollectionsView()
//                }
//                .tabItem {
//                    Label("Coleções", systemImage: "rectangle.grid.2x2.fill")
//                }
//                .tag(PhoneTab.collections)
                
                NavigationView {
                    TrendsView(tabSelection: $tabSelection,
                               activePadScreen: .constant(.trends))
                        .environmentObject(trendsHelper)
                }
                .tabItem {
                    Label("Tendências", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(PhoneTab.trends)
                
                NavigationView {
                    SongsView()
                        .environmentObject(settingsHelper)
                }
                .tabItem {
                    Label("Músicas", systemImage: "music.quarternote.3")
                }
                .tag(PhoneTab.songs)
            }
            .onContinueUserActivity(Shared.ActivityTypes.playAndShareSounds, perform: { _ in
                tabSelection = .sounds
            })
//            .onContinueUserActivity(Shared.ActivityTypes.viewCollections, perform: { _ in
//                tabSelection = .collections
//            })
            .onContinueUserActivity(Shared.ActivityTypes.playAndShareSongs, perform: { _ in
                tabSelection = .songs
            })
            .onContinueUserActivity(Shared.ActivityTypes.viewLast24HoursTopChart, perform: { _ in
                tabSelection = .trends
                trendsHelper.timeIntervalToGoTo = .last24Hours
            })
            .onContinueUserActivity(Shared.ActivityTypes.viewLastWeekTopChart, perform: { _ in
                tabSelection = .trends
                trendsHelper.timeIntervalToGoTo = .lastWeek
            })
            .onContinueUserActivity(Shared.ActivityTypes.viewLastMonthTopChart, perform: { _ in
                tabSelection = .trends
                trendsHelper.timeIntervalToGoTo = .lastMonth
            })
            .onContinueUserActivity(Shared.ActivityTypes.viewAllTimeTopChart, perform: { _ in
                tabSelection = .trends
                trendsHelper.timeIntervalToGoTo = .allTime
            })
        } else {
            NavigationView {
                SidebarView(state: $state,
                            isShowingSettingsSheet: $isShowingSettingsSheet,
                            isShowingFolderInfoEditingSheet: $isShowingFolderInfoEditingSheet,
                            updateFolderList: $updateFolderList)
                    .environmentObject(trendsHelper)
                    .environmentObject(settingsHelper)
                SoundsView(viewModel: SoundsViewViewModel(soundSortOption: UserSettings.getSoundSortOption(),
                                                          authorSortOption: AuthorSortOption.nameAscending.rawValue),
                           currentMode: .allSounds)
                    .environmentObject(trendsHelper)
                    .environmentObject(settingsHelper)
            }
            .navigationViewStyle(DoubleColumnNavigationViewStyle())
            .sheet(isPresented: $isShowingSettingsSheet) {
                SettingsCasingWithCloseView(isBeingShown: $isShowingSettingsSheet)
                    .environmentObject(settingsHelper)
            }
            .sheet(isPresented: $isShowingFolderInfoEditingSheet, onDismiss: {
                updateFolderList = true
            }) {
                FolderInfoEditingView(isBeingShown: $isShowingFolderInfoEditingSheet, selectedBackgroundColor: "pastelPurple")
            }
        }
    }

}

struct MainView_Previews: PreviewProvider {

    static var previews: some View {
        MainView()
    }

}
