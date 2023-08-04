//
//  MainView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 19/05/22.
//

import SwiftUI

struct MainView: View {

    @StateObject var viewModel: MainViewViewModel

    @State var tabSelection: PhoneTab = .sounds
    @State var state: PadScreen? = PadScreen.allSounds
    @State var isShowingSettingsSheet: Bool = false
    @StateObject var settingsHelper = SettingsHelper()
    @State var isShowingFolderInfoEditingSheet: Bool = false
    @State var updateFolderList: Bool = false
    @State var currentSoundsListMode: SoundsListMode = .regular
    
    // Trends
    @State var soundIdToGoToFromTrends: String = .empty
    @StateObject var trendsHelper = TrendsHelper()
    
    var body: some View {
        ZStack {
            if UIDevice.current.userInterfaceIdiom == .phone {
                TabView(selection: $tabSelection) {
                    NavigationView {
                        SoundsView(viewModel: SoundsViewViewModel(soundSortOption: UserSettings.getSoundSortOption(),
                                                                  authorSortOption: AuthorSortOption.nameAscending.rawValue,
                                                                  currentSoundsListMode: $currentSoundsListMode),
                                   currentViewMode: .allSounds,
                                   currentSoundsListMode: $currentSoundsListMode,
                                   updateList: $viewModel.updateSoundList)
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
                        SongsView()
                            .environmentObject(settingsHelper)
                    }
                    .tabItem {
                        Label("Músicas", systemImage: "music.quarternote.3")
                    }
                    .tag(PhoneTab.songs)
                    
                    NavigationView {
                        TrendsView(tabSelection: $tabSelection,
                                   activePadScreen: .constant(.trends))
                        .environmentObject(trendsHelper)
                    }
                    .tabItem {
                        Label("Tendências", systemImage: "chart.line.uptrend.xyaxis")
                    }
                    .tag(PhoneTab.trends)
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
                                updateFolderList: $updateFolderList,
                                currentSoundsListMode: $currentSoundsListMode,
                                updateSoundList: $viewModel.updateSoundList)
                    .environmentObject(trendsHelper)
                    .environmentObject(settingsHelper)
                    
                    SoundsView(viewModel: SoundsViewViewModel(soundSortOption: UserSettings.getSoundSortOption(),
                                                              authorSortOption: AuthorSortOption.nameAscending.rawValue,
                                                              currentSoundsListMode: $currentSoundsListMode),
                               currentViewMode: .allSounds,
                               currentSoundsListMode: $currentSoundsListMode,
                               updateList: $viewModel.updateSoundList)
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
                    FolderInfoEditingView(isBeingShown: $isShowingFolderInfoEditingSheet, selectedBackgroundColor: Shared.Folders.defaultFolderColor)
                }
            }
            
            if viewModel.showSyncProgressView {
                OverlaySyncProgressView(message: $viewModel.message, currentValue: $viewModel.currentAmount, totalValue: $viewModel.totalAmount)
            }
        }
        .onAppear {
            print("RuPaul")

            Task { @MainActor in
                //await viewModel.sync()
            }

//            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
//                totalAmount = 3
//                message = "Atualizando dados (0/3)..."
//            }
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
//                currentAmount = 1
//                message = "Atualizando dados (1/3)..."
//            }
        }
    }
}

struct MainView_Previews: PreviewProvider {

    static var previews: some View {
        MainView(viewModel: MainViewViewModel(lastUpdateDate: "all",
                                              service: SyncService(connectionManager: ConnectionManager.shared,
                                                                   networkRabbit: NetworkRabbit(serverPath: ""),
                                                                   localDatabase: LocalDatabase()),
                                              database: LocalDatabase(),
                                              logger: Logger()))
    }
}
