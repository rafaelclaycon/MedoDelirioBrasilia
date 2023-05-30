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
    @State var currentSoundsListMode: SoundsListMode = .regular
    
    // Trends
    @State var soundIdToGoToFromTrends: String = .empty
    @StateObject var trendsHelper = TrendsHelper()
    
    // Sync
    @State private var showSyncProgressView = false
    @State var currentAmount = 0.0
    @State var totalAmount = 0.0
    @AppStorage("lastUpdateDate") private var lastUpdateDate = "all"
    @State private var localUnsuccessfulUpdates: [UpdateEvent]? = nil
    @State private var serverUpdates: [UpdateEvent]? = nil
    @State private var updateSoundList: Bool = false
    
    private let service = SyncService(connectionManager: ConnectionManager.shared,
                                      networkRabbit: networkRabbit,
                                      localDatabase: database)
    
    var body: some View {
        ZStack {
            if UIDevice.current.userInterfaceIdiom == .phone {
                TabView(selection: $tabSelection) {
                    NavigationView {
                        NewSoundsView(updateList: $updateSoundList)
//                        SoundsView(viewModel: SoundsViewViewModel(soundSortOption: UserSettings.getSoundSortOption(),
//                                                                  authorSortOption: AuthorSortOption.nameAscending.rawValue,
//                                                                  currentSoundsListMode: $currentSoundsListMode),
//                                   currentViewMode: .allSounds,
//                                   currentSoundsListMode: $currentSoundsListMode)
//                        .environmentObject(trendsHelper)
//                        .environmentObject(settingsHelper)
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
                                currentSoundsListMode: $currentSoundsListMode)
                    .environmentObject(trendsHelper)
                    .environmentObject(settingsHelper)
                    SoundsView(viewModel: SoundsViewViewModel(soundSortOption: UserSettings.getSoundSortOption(),
                                                              authorSortOption: AuthorSortOption.nameAscending.rawValue,
                                                              currentSoundsListMode: $currentSoundsListMode),
                               currentViewMode: .allSounds,
                               currentSoundsListMode: $currentSoundsListMode)
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
            
            if showSyncProgressView {
                OverlaySyncProgressView(message: "Atualizando dados...")
            }
        }
        .onAppear {
            sync()
        }
    }
    
    private func sync() {
        Task { @MainActor in
            do {
                try await retryLocal()
                try await syncDataWithServer()
                updateSoundList = true
                showSyncProgressView = false
            } catch {
                print(error)
            }
        }
    }
    
    private func retryLocal() async throws {
        let localResult = try await fetchLocalUnsuccessfulUpdates()
        print("Resultado do fetchLocalUnsuccessfulUpdates: \(localResult)")
        if localResult > 0 {
            await MainActor.run {
                showSyncProgressView = true
                totalAmount = localResult
            }
            try await syncUnsuccessful()
        }
    }
    
    private func syncDataWithServer() async throws {
        let result = try await fetchServerUpdates()
        print("Resultado do fetchServerUpdates: \(result)")
        if result > 0 {
            await MainActor.run {
                showSyncProgressView = true
                totalAmount = result
            }
            try await serverSync()
        }
    }
    
    private func fetchServerUpdates() async throws -> Double {
        print("fetchServerUpdates()")
        serverUpdates = try await service.getUpdates(from: lastUpdateDate)
        if var serverUpdates = serverUpdates {
            for i in serverUpdates.indices {
                serverUpdates[i].didSucceed = false
                try database.insert(updateEvent: serverUpdates[i])
            }
        }
        return Double(serverUpdates?.count ?? 0)
    }
    
    private func fetchLocalUnsuccessfulUpdates() async throws -> Double {
        print("fetchLocalUnsuccessfulUpdates()")
        localUnsuccessfulUpdates = try database.unsuccessfulUpdates()
        return Double(localUnsuccessfulUpdates?.count ?? 0)
    }
    
    private func serverSync() async throws {
        print("serverSync()")
        guard let serverUpdates = serverUpdates else { return }
        guard serverUpdates.isEmpty == false else {
            return print("NO UPDATES")
        }
        guard service.hasConnectivity() else {
            throw SyncError.noInternet
        }
        
        currentAmount = 0.0
        for update in serverUpdates {
            await service.process(updateEvent: update)
            sleep(1)
            await MainActor.run {
                currentAmount += 1.0
            }
        }
        
        lastUpdateDate = Date.now.iso8601withFractionalSeconds
        //print(Date.now.iso8601withFractionalSeconds)
    }
    
    private func syncUnsuccessful() async throws {
        print("syncUnsucceeded()")
        guard let localUnsuccessfulUpdates = localUnsuccessfulUpdates else { return }
        guard localUnsuccessfulUpdates.isEmpty == false else {
            return print("NO LOCAL UNSUCCESSFUL UPDATES")
        }
        guard service.hasConnectivity() else {
            throw SyncError.noInternet
        }
        
        currentAmount = 0.0
        for update in localUnsuccessfulUpdates {
            await service.process(updateEvent: update)
            sleep(1)
            await MainActor.run {
                currentAmount += 1.0
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {

    static var previews: some View {
        MainView()
    }

}
