//
//  MainView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 19/05/22.
//

import SwiftUI

struct MainView: View {

    @Binding var tabSelection: PhoneTab
    @Binding var padSelection: PadScreen?

    @State private var soundsPath = NavigationPath()
    @State private var favoritesPath = NavigationPath()
    @State private var reactionsPath = NavigationPath()
    @State private var authorsPath = NavigationPath()
    @State private var foldersPath = NavigationPath()

    @State private var isShowingSettingsSheet: Bool = false
    @State private var settingsHelper = SettingsHelper()
    @State private var folderForEditing: UserFolder?
    @State private var updateFolderList: Bool = false
    @State private var currentContentListMode: ContentGridMode = .regular
    @State private var toast: Toast?
    @State private var floatingOptions: FloatingContentOptions?

    @State private var subviewToOpen: MainViewModalToOpen = .onboarding
    @State private var showingModalView: Bool = false

    // iPad
    @State private var sidebarViewModel = SidebarViewModel(
        userFolderRepository: UserFolderRepository(database: LocalDatabase.shared)
    )
    @State private var authorSortOption: Int = 0
    @State private var authorSortAction: AuthorSortOption = .nameAscending

    // Trends
    @State private var soundIdToGoToFromTrends: String = ""
    @State private var trendsHelper = TrendsHelper()

    // Sync
    @State private var syncValues = SyncValues()

    @State private var contentRepository = ContentRepository(database: LocalDatabase.shared)

    // MARK: - View Body

    var body: some View {
        ZStack {
            if UIDevice.isiPhone {
                TabView(selection: $tabSelection) {
                    NavigationStack(path: $soundsPath) {
                        MainContentView(
                            viewModel: MainContentViewModel(
                                currentViewMode: .all,
                                contentSortOption: UserSettings().mainSoundListSoundSortOption(),
                                authorSortOption: UserSettings().authorSortOption(),
                                currentContentListMode: $currentContentListMode,
                                toast: $toast,
                                floatingOptions: $floatingOptions,
                                syncValues: syncValues,
                                contentRepository: contentRepository,
                                analyticsService: AnalyticsService()
                            ),
                            currentContentListMode: $currentContentListMode,
                            toast: $toast,
                            floatingOptions: $floatingOptions,
                            openSettingsAction: {
                                isShowingSettingsSheet.toggle()
                            },
                            contentRepository: contentRepository,
                            bannerRepository: BannerRepository()
                        )
                        .environment(trendsHelper)
                        .environment(settingsHelper)
                        .navigationDestination(for: GeneralNavigationDestination.self) { screen in
                            GeneralRouter(destination: screen, contentRepository: contentRepository)
                        }
                    }
                    .tabItem {
                        Label("Sons", systemImage: "speaker.wave.3.fill")
                    }
                    .tag(PhoneTab.sounds)
                    .environment(\.push, PushAction { soundsPath.append($0) })

                    NavigationStack(path: $reactionsPath) {
                        ReactionsView()
                            .environment(trendsHelper)
                            .navigationDestination(for: GeneralNavigationDestination.self) { screen in
                                GeneralRouter(destination: screen, contentRepository: contentRepository)
                            }
                    }
                    .tabItem {
                        Label("Reações", systemImage: "rectangle.grid.2x2.fill")
                    }
                    .tag(PhoneTab.reactions)
                    .environment(\.push, PushAction { reactionsPath.append($0) })

//                    NavigationView {
//                        SongsView()
//                            .environmentObject(settingsHelper)
//                            .environment(trendsHelper)
//                    }
//                    .tabItem {
//                        Label("Músicas", systemImage: "music.quarternote.3")
//                    }
//                    .tag(PhoneTab.songs)
                    
                    NavigationView {
                        TrendsView(
                            tabSelection: $tabSelection,
                            activePadScreen: .constant(.trends)
                        )
                        .environment(trendsHelper)
                    }
                    .tabItem {
                        Label("Tendências", systemImage: "chart.line.uptrend.xyaxis")
                    }
                    .tag(PhoneTab.trends)
                }
                .onContinueUserActivity(Shared.ActivityTypes.playAndShareSounds, perform: { _ in
                    tabSelection = .sounds
                })
//                .onContinueUserActivity(Shared.ActivityTypes.viewCollections, perform: { _ in
//                    tabSelection = .collections
//                })
//                .onContinueUserActivity(Shared.ActivityTypes.playAndShareSongs, perform: { _ in
//                    tabSelection = .songs
//                })
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
                if #available(iOS 18, *) {
                    TabView {
                        Tab("Sons", systemImage: "speaker.wave.2") {
                            NavigationStack(path: $soundsPath) {
                                MainContentView(
                                    viewModel: MainContentViewModel(
                                        currentViewMode: .all,
                                        contentSortOption: UserSettings().mainSoundListSoundSortOption(),
                                        authorSortOption: UserSettings().authorSortOption(),
                                        currentContentListMode: $currentContentListMode,
                                        toast: $toast,
                                        floatingOptions: $floatingOptions,
                                        syncValues: syncValues,
                                        contentRepository: contentRepository,
                                        analyticsService: AnalyticsService()
                                    ),
                                    currentContentListMode: $currentContentListMode,
                                    toast: $toast,
                                    floatingOptions: $floatingOptions,
                                    openSettingsAction: {},
                                    contentRepository: contentRepository,
                                    bannerRepository: BannerRepository()
                                )
                                .environment(trendsHelper)
                                .environment(settingsHelper)
                                .navigationDestination(for: GeneralNavigationDestination.self) { screen in
                                    GeneralRouter(destination: screen, contentRepository: contentRepository)
                                }
                            }
                            .environment(\.push, PushAction { soundsPath.append($0) })
                        }

                        Tab("Favoritos", systemImage: "star") {
                            NavigationStack(path: $favoritesPath) {
                                StandaloneFavoritesView(
                                    viewModel: StandaloneFavoritesViewModel(
                                        contentSortOption: UserSettings().mainSoundListSoundSortOption(),
                                        toast: $toast,
                                        floatingOptions: $floatingOptions,
                                        contentRepository: contentRepository
                                    ),
                                    currentContentListMode: $currentContentListMode,
                                    openSettingsAction: {},
                                    contentRepository: contentRepository
                                )
                                .environment(trendsHelper)
                                .environment(settingsHelper)
                                .navigationDestination(for: GeneralNavigationDestination.self) { screen in
                                    GeneralRouter(destination: screen, contentRepository: contentRepository)
                                }
                            }
                            .environment(\.push, PushAction { favoritesPath.append($0) })
                        }

                        Tab("Reações", systemImage: "rectangle.grid.2x2") {
                            NavigationStack(path: $reactionsPath) {
                                ReactionsView()
                                    .environment(trendsHelper)
                                    .navigationDestination(for: GeneralNavigationDestination.self) { screen in
                                        GeneralRouter(destination: screen, contentRepository: contentRepository)
                                    }
                            }
                            .environment(\.push, PushAction { reactionsPath.append($0) })
                        }

                        Tab("Autores", systemImage: "person") {
                            NavigationStack(path: $authorsPath) {
                                StandaloneAuthorsView()
                                    .navigationDestination(for: GeneralNavigationDestination.self) { screen in
                                        GeneralRouter(destination: screen, contentRepository: contentRepository)
                                    }
                            }
                            .environment(\.push, PushAction { authorsPath.append($0) })
                        }

                        Tab("Tendências", systemImage: "chart.line.uptrend.xyaxis") {
                            NavigationStack {
                                TrendsView(
                                    tabSelection: $tabSelection,
                                    activePadScreen: .constant(.trends)
                                )
                                .environment(trendsHelper)
                            }
                        }

                        TabSection("Minhas Pastas") {
                            Tab("Todas as Pastas", systemImage: "folder") {
                                NavigationStack(path: $foldersPath) {
                                    StandaloneFolderGridView(
                                        folderForEditing: $folderForEditing,
                                        updateFolderList: $updateFolderList,
                                        contentRepository: contentRepository
                                    )
                                    .navigationDestination(for: GeneralNavigationDestination.self) { screen in
                                        GeneralRouter(destination: screen, contentRepository: contentRepository)
                                    }
                                }
                                .environment(\.push, PushAction { foldersPath.append($0) })
                            }

                            switch sidebarViewModel.state {
                            case .loading:
                                Tab {
                                    EmptyView()
                                } label: {
                                    ProgressView()
                                }

                            case .loaded(let folders):
                                ForEach(folders) { folder in
                                    Tab {
                                        NavigationStack {
                                            FolderDetailView(
                                                viewModel: FolderDetailViewModel(
                                                    folder: folder,
                                                    contentRepository: contentRepository
                                                ),
                                                folder: folder,
                                                currentContentListMode: $currentContentListMode,
                                                toast: $toast,
                                                floatingOptions: $floatingOptions,
                                                contentRepository: contentRepository
                                            )
                                        }
                                    } label: {
                                        Text("\(folder.symbol)   \(folder.name)")
                                            .padding()
                                    }
                                }

                            case .error(_):
                                Tab {
                                    EmptyView()
                                } label: {
                                    Text("Erro carregando as pastas.")
                                }
                            }
                        }
                        .sectionActions {
                            Button {
                                folderForEditing = UserFolder.newFolder()
                            } label: {
                                Label("Nova Pasta", systemImage: "plus")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                    .tabViewStyle(.sidebarAdaptable)
                    .tabViewSidebarHeader {
                        HStack {
                            Text("Medo e Delírio")
                                .font(.title)
                                .bold()

                            Spacer()
                        }
                    }
                    .tabViewSidebarFooter {
                        HStack {
                            Button {
                                isShowingSettingsSheet.toggle()
                            } label: {
                                Label("Configurações", systemImage: "gearshape")
                            }

                            Spacer()
                        }
                        .padding(.top, 30)
                    }
                    .onAppear {
                        Task {
                            await sidebarViewModel.onViewAppeared()
                        }
                    }
                } else {
                    NavigationSplitView {
                        SidebarView(
                            state: $padSelection,
                            isShowingSettingsSheet: $isShowingSettingsSheet,
                            folderForEditing: $folderForEditing,
                            updateFolderList: $updateFolderList,
                            currentContentListMode: $currentContentListMode,
                            toast: $toast,
                            floatingOptions: $floatingOptions,
                            contentRepository: contentRepository
                        )
                        .environment(trendsHelper)
                        .environment(settingsHelper)
                        .environment(syncValues)
                    } detail: {
                        NavigationStack(path: $soundsPath) {
                            MainContentView(
                                viewModel: MainContentViewModel(
                                    currentViewMode: .all,
                                    contentSortOption: UserSettings().mainSoundListSoundSortOption(),
                                    authorSortOption: AuthorSortOption.nameAscending.rawValue,
                                    currentContentListMode: $currentContentListMode,
                                    toast: $toast,
                                    floatingOptions: $floatingOptions,
                                    syncValues: syncValues,
                                    contentRepository: contentRepository,
                                    analyticsService: AnalyticsService()
                                ),
                                currentContentListMode: $currentContentListMode,
                                toast: $toast,
                                floatingOptions: $floatingOptions,
                                openSettingsAction: {},
                                contentRepository: contentRepository,
                                bannerRepository: BannerRepository()
                            )
                            .environment(trendsHelper)
                            .environment(settingsHelper)
                            .navigationDestination(for: GeneralNavigationDestination.self) { screen in
                                GeneralRouter(destination: screen, contentRepository: contentRepository)
                            }
                            .environment(\.push, PushAction { soundsPath.append($0) })
                        }
                    }
                }
            }
        }
        .environment(syncValues)
        .onAppear {
            print("MAIN VIEW - ON APPEAR")
            sendUserPersonalTrendsToServerIfEnabled()
            displayOnboardingIfNeeded()
        }
        .sheet(isPresented: $showingModalView) {
            switch subviewToOpen {
            case .settings:
                SettingsCasingWithCloseView(isBeingShown: $showingModalView)
                    .environment(settingsHelper)

            case .onboarding:
                FirstOnboardingView(isBeingShown: $showingModalView)
                    .interactiveDismissDisabled(UIDevice.isiPhone)

            case .whatsNew:
                Version9WhatsNewView(appMemory: AppPersistentMemory())
                    .interactiveDismissDisabled()

            case .retrospective:
                EmptyView()
            }
        }
        .sheet(item: $folderForEditing) { folder in
            FolderInfoEditingView(
                folder: folder,
                folderRepository: UserFolderRepository(database: LocalDatabase.shared),
                dismissSheet: {
                    folderForEditing = nil
                    updateFolderList = true
                }
            )
        }
        // Could be removed in the future, but for now using `showingModalView` bugs out on iPad. Shows Onboarding most of the time.
        .sheet(isPresented: $isShowingSettingsSheet) {
            SettingsCasingWithCloseView(isBeingShown: $isShowingSettingsSheet)
                .environment(settingsHelper)
        }
    }

    // MARK: - Functions

    private func sendUserPersonalTrendsToServerIfEnabled() {
        Task {
            guard UserSettings().getEnableTrends() else {
                return
            }
            guard UserSettings().getEnableShareUserPersonalTrends() else {
                return
            }

            if let lastDate = AppPersistentMemory().getLastSendDateOfUserPersonalTrendsToServer() {
                if lastDate.onlyDate! < Date.now.onlyDate! {
                    let result = await Podium.shared.sendShareCountStatsToServer()

                    guard result == .successful || result == .noStatsToSend else {
                        return
                    }
                    AppPersistentMemory().setLastSendDateOfUserPersonalTrendsToServer(to: Date.now.onlyDate!)
                }
            } else {
                let result = await Podium.shared.sendShareCountStatsToServer()

                guard result == .successful || result == .noStatsToSend else {
                    return
                }
                AppPersistentMemory().setLastSendDateOfUserPersonalTrendsToServer(to: Date.now.onlyDate!)
            }
        }
    }

    private func displayOnboardingIfNeeded() {
        if !AppPersistentMemory().hasShownNotificationsOnboarding() {
            subviewToOpen = .onboarding
            showingModalView = true
        } else if !AppPersistentMemory().hasSeenVersion9WhatsNewScreen() {
            subviewToOpen = .whatsNew
            showingModalView = true
        }
    }
}

// MARK: - Preview

#Preview {
    MainView(
        tabSelection: .constant(.sounds),
        padSelection: .constant(.allSounds)
    )
}
