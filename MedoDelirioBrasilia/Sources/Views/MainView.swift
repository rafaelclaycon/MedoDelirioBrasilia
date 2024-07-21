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
    @State private var path = NavigationPath()

    @State var isShowingSettingsSheet: Bool = false
    @StateObject var settingsHelper = SettingsHelper()
    @State var isShowingFolderInfoEditingSheet: Bool = false
    @State var updateFolderList: Bool = false
    @State var currentSoundsListMode: SoundsListMode = .regular

    @State private var subviewToOpen: MainViewModalToOpen = .onboarding
    @State private var showingModalView: Bool = false
    @State private var triggerSettings: Bool = false

    // Trends
    @State var soundIdToGoToFromTrends: String = .empty
    @StateObject var trendsHelper = TrendsHelper()

    // Sync
    let networkMonitor = NetworkMonitor()
    @StateObject private var syncValues = SyncValues()

    // MARK: - View Body

    var body: some View {
        ZStack {
            if UIDevice.isiPhone {
                TabView(selection: $tabSelection) {
                    NavigationStack(path: $path) {
                        MainSoundContainer(
                            viewModel: .init(
                                currentViewMode: .allSounds,
                                soundSortOption: UserSettings.mainSoundListSoundSortOption(),
                                authorSortOption: UserSettings.authorSortOption(),
                                currentSoundsListMode: $currentSoundsListMode,
                                syncValues: syncValues
                            ),
                            currentSoundsListMode: $currentSoundsListMode,
                            showSettings: $triggerSettings
                        )
                        .environmentObject(trendsHelper)
                        .environmentObject(settingsHelper)
                        .environmentObject(networkMonitor)
                        .navigationDestination(for: SoundListNavigationDestination.self) { screen in
                            SoundListRouter(destination: screen)
                        }
                    }
                    .tabItem {
                        Label("Sons", systemImage: "speaker.wave.3.fill")
                    }
                    .tag(PhoneTab.sounds)
                    .environment(\.push, PushAction { path.append($0) })

                    NavigationView {
                        ReactionsView()
                    }
                    .tabItem {
                        Label("Reações", systemImage: "rectangle.grid.2x2.fill")
                    }
                    .tag(PhoneTab.reactions)

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
                    SidebarView(
                        state: $state,
                        isShowingSettingsSheet: $isShowingSettingsSheet,
                        isShowingFolderInfoEditingSheet: $isShowingFolderInfoEditingSheet,
                        updateFolderList: $updateFolderList,
                        currentSoundsListMode: $currentSoundsListMode
                    )
                    .environmentObject(trendsHelper)
                    .environmentObject(settingsHelper)
                    .environmentObject(networkMonitor)
                    .environmentObject(syncValues)

                    MainSoundContainer(
                        viewModel: .init(
                            currentViewMode: .allSounds,
                            soundSortOption: UserSettings.mainSoundListSoundSortOption(),
                            authorSortOption: AuthorSortOption.nameAscending.rawValue,
                            currentSoundsListMode: $currentSoundsListMode,
                            syncValues: syncValues
                        ),
                        currentSoundsListMode: $currentSoundsListMode,
                        showSettings: .constant(false)
                    )
                    .environmentObject(trendsHelper)
                    .environmentObject(settingsHelper)
                    .environmentObject(networkMonitor)
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
        }
        .environmentObject(syncValues)
        .onAppear {
            print("MAIN VIEW - ON APPEAR")
            sendUserPersonalTrendsToServerIfEnabled()
            displayOnboardingIfNeeded()
        }
        .onChange(of: triggerSettings) { show in
            if show {
                subviewToOpen = .settings
                showingModalView = true
                triggerSettings = false
            }
        }
        .sheet(isPresented: $showingModalView) {
            switch subviewToOpen {
            case .settings:
                SettingsCasingWithCloseView(isBeingShown: $showingModalView)
                    .environmentObject(settingsHelper)

            case .onboarding:
                FirstOnboardingView(isBeingShown: $showingModalView)
                    .interactiveDismissDisabled(UIDevice.current.userInterfaceIdiom == .phone ? true : false)

            case .whatsNew:
                IntroducingReactionsView(isBeingShown: $showingModalView)
                    .interactiveDismissDisabled()

            case .retrospective:
                EmptyView()
            }
        }
    }

    // MARK: - Functions

    private func sendUserPersonalTrendsToServerIfEnabled() {
        Task {
            guard UserSettings.getEnableTrends() else {
                return
            }
            guard UserSettings.getEnableShareUserPersonalTrends() else {
                return
            }

            if let lastDate = AppPersistentMemory.getLastSendDateOfUserPersonalTrendsToServer() {
                if lastDate.onlyDate! < Date.now.onlyDate! {
                    let result = await Podium.shared.sendShareCountStatsToServer()

                    guard result == .successful || result == .noStatsToSend else {
                        return
                    }
                    AppPersistentMemory.setLastSendDateOfUserPersonalTrendsToServer(to: Date.now.onlyDate!)
                }
            } else {
                let result = await Podium.shared.sendShareCountStatsToServer()

                guard result == .successful || result == .noStatsToSend else {
                    return
                }
                AppPersistentMemory.setLastSendDateOfUserPersonalTrendsToServer(to: Date.now.onlyDate!)
            }
        }
    }

    private func displayOnboardingIfNeeded() {
        if !AppPersistentMemory.hasShownNotificationsOnboarding() {
            subviewToOpen = .onboarding
            showingModalView = true
        } else if !AppPersistentMemory.hasSeenReactionsWhatsNewScreen() {
            subviewToOpen = .whatsNew
            showingModalView = true
        }
    }
}

#Preview {
    MainView()
}
