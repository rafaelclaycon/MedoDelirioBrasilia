//
//  MainView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 19/05/22.
//

import SwiftUI

struct MainView: View {

    private var tabSelection: Binding<PhoneTab>
    private var padSelection: Binding<PadScreen?>

    @State private var soundsPath = NavigationPath()
    @State private var favoritesPath = NavigationPath()
    @State private var reactionsPath = NavigationPath()
    @State private var authorsPath = NavigationPath()
    @State private var searchTabPath = NavigationPath()
    @State private var foldersPath = NavigationPath()
    @State private var episodesPath = NavigationPath()

    @State private var isShowingSettingsSheet: Bool = false
    @State private var settingsHelper = SettingsHelper()
    @State private var folderForEditing: UserFolder?
    @State private var updateFolderList: Bool = false
    @State private var currentContentListMode: ContentGridMode = .regular
    @State private var toast: Toast?
    @State private var floatingOptions: FloatingContentOptions?

    @State private var subviewToOpen: MainViewModalToOpen = .onboarding
    @State private var showingModalView: Bool = false
    @State private var showUniversalSearchWhatsNew: Bool = false

    // iPad
    @State private var sidebarFoldersViewModel: SidebarFoldersViewModel
    @State private var authorSortOption: Int = 0
    @State private var authorSortAction: AuthorSortOption = .nameAscending

    // Trends
    @State private var soundIdToGoToFromTrends: String = ""
    @State private var trendsHelper = TrendsHelper()

    // Content Update
    @State private var syncValues = SyncValues()

    // Episodes
    @State private var episodePlayer = EpisodePlayer()
    @State private var episodeFavoritesStore = EpisodeFavoritesStore()
    @State private var episodeProgressStore = EpisodeProgressStore()
    @State private var episodePlayedStore = EpisodePlayedStore()
    @State private var episodeBookmarkStore = EpisodeBookmarkStore()
    @State private var showNowPlaying = false

    @State private var contentRepository: ContentRepository
    private let trendsService = TrendsService.shared
    @State private var reactionRepository = ReactionRepository()

    private let userFolderRepository: UserFolderRepositoryProtocol
    private let searchService: SearchService

    init(
        tabSelection: Binding<PhoneTab>,
        padSelection: Binding<PadScreen?>,
        contentRepository: ContentRepository = ContentRepository(database: LocalDatabase.shared),
        userFolderRepository: UserFolderRepositoryProtocol = UserFolderRepository(database: LocalDatabase.shared)
    ) {
        self.tabSelection = tabSelection
        self.padSelection = padSelection
        self.contentRepository = contentRepository
        self.userFolderRepository = userFolderRepository
        self._sidebarFoldersViewModel = State(initialValue: SidebarFoldersViewModel(userFolderRepository: userFolderRepository))

        // Create a single shared SearchService instance
        self.searchService = SearchService(
            contentRepository: contentRepository,
            authorService: AuthorService(database: LocalDatabase.shared),
            appMemory: AppPersistentMemory.shared,
            userFolderRepository: userFolderRepository,
            userSettings: UserSettings(),
            reactionRepository: ReactionRepository()
        )
    }

    // MARK: - View Body

    var body: some View {
        ZStack {
            if UIDevice.isiPhone {
                if #available(iOS 26.0, *) {
                    TabView(selection: tabSelection) {
                        Tab(Shared.TabInfo.name(.sounds), systemImage: Shared.TabInfo.symbol(.sounds), value: .sounds) {
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
                                userFolderRepository: userFolderRepository,
                                bannerRepository: BannerRepository(),
                                searchService: searchService,
                                analyticsService: AnalyticsService()
                            )
                            .environment(trendsHelper)
                            .environment(settingsHelper)
                            .navigationDestination(for: GeneralNavigationDestination.self) { screen in
                                GeneralRouter(destination: screen, contentRepository: contentRepository)
                            }
                        }
                        .tag(PhoneTab.sounds)
                        .environment(\.push, PushAction { soundsPath.append($0) })
                    }

                    Tab(Shared.TabInfo.name(PhoneTab.reactions), systemImage: Shared.TabInfo.symbol(PhoneTab.reactions), value: .reactions) {
                        NavigationStack(path: $reactionsPath) {
                            ReactionsView()
                                .environment(trendsHelper)
                                .navigationDestination(for: GeneralNavigationDestination.self) { screen in
                                    GeneralRouter(destination: screen, contentRepository: contentRepository)
                                }
                        }
                        .tag(PhoneTab.reactions)
                        .environment(\.push, PushAction { reactionsPath.append($0) })
                    }

                    if FeatureFlag.isEnabled(.episodes) {
                        Tab("Episódios", systemImage: "radio", value: .trends) {
                            NavigationStack(path: $episodesPath) {
                                EpisodesView()
                                    .navigationDestination(for: PodcastEpisode.self) { episode in
                                        EpisodeDetailView(episode: episode)
                                    }
                            }
                            .environment(\.push, PushAction { episodesPath.append($0) })
                            .tag(PhoneTab.trends)
                        }
                    } else {
                        Tab(Shared.TabInfo.name(PhoneTab.trends), systemImage: Shared.TabInfo.symbol(PhoneTab.trends), value: .trends) {
                            NavigationView {
                                TrendsView(
                                    audienceViewModel: MostSharedByAudienceView.ViewModel(trendsService: trendsService),
                                    tabSelection: tabSelection,
                                    activePadScreen: .constant(.trends)
                                )
                                .environment(trendsHelper)
                            }
                            .tag(PhoneTab.trends)
                        }
                    }

                    Tab(value: .search, role: .search) {
                        NavigationStack(path: $searchTabPath) {
                            StandaloneSearchView(
                                searchService: searchService,
                                trendsService: trendsService,
                                contentRepository: contentRepository,
                                userFolderRepository: userFolderRepository,
                                analyticsService: AnalyticsService()
                            )
                                .navigationDestination(for: GeneralNavigationDestination.self) { screen in
                                    GeneralRouter(destination: screen, contentRepository: contentRepository)
                                }
                            }
                            .environment(\.push, PushAction { searchTabPath.append($0) })
                        }
                    }
                    .if(FeatureFlag.isEnabled(.episodes) && episodePlayer.currentEpisode != nil) { view in
                        view.tabViewBottomAccessory {
                            if let episode = episodePlayer.currentEpisode {
                                NowPlayingAccessoryView(episode: episode, player: episodePlayer)
                                    .onTapGesture {
                                        showNowPlaying = true
                                    }
                            }
                        }
                    }
                    .sheet(isPresented: $showNowPlaying) {
                        NowPlayingView()
                            .environment(episodePlayer)
                            .environment(episodeBookmarkStore)
                    }
                    .tabBarMinimizeBehavior(.onScrollDown)
                } else {
                    TabView(selection: tabSelection) {
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
                                userFolderRepository: userFolderRepository,
                                bannerRepository: BannerRepository(),
                                searchService: searchService,
                                analyticsService: AnalyticsService()
                            )
                            .environment(trendsHelper)
                            .environment(settingsHelper)
                            .navigationDestination(for: GeneralNavigationDestination.self) { screen in
                                GeneralRouter(destination: screen, contentRepository: contentRepository)
                            }
                        }
                        .tabItem {
                            Label(Shared.TabInfo.name(.sounds), systemImage: Shared.TabInfo.symbol(.sounds))
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
                            Label(Shared.TabInfo.name(PhoneTab.reactions), systemImage: Shared.TabInfo.symbol(PhoneTab.reactions))
                        }
                        .tag(PhoneTab.reactions)
                        .environment(\.push, PushAction { reactionsPath.append($0) })

                        if FeatureFlag.isEnabled(.episodes) {
                            NavigationStack(path: $episodesPath) {
                                EpisodesView()
                                    .navigationDestination(for: PodcastEpisode.self) { episode in
                                        EpisodeDetailView(episode: episode)
                                    }
                            }
                            .environment(\.push, PushAction { episodesPath.append($0) })
                            .tabItem {
                                Label("Episódios", systemImage: "radio")
                            }
                            .tag(PhoneTab.trends)
                        } else {
                            NavigationView {
                                TrendsView(
                                    audienceViewModel: MostSharedByAudienceView.ViewModel(trendsService: trendsService),
                                    tabSelection: tabSelection,
                                    activePadScreen: .constant(.trends)
                                )
                                .environment(trendsHelper)
                            }
                            .tabItem {
                                Label(Shared.TabInfo.name(PhoneTab.trends), systemImage: Shared.TabInfo.symbol(PhoneTab.trends))
                            }
                            .tag(PhoneTab.trends)
                        }
                    }
                    .onContinueUserActivity(Shared.ActivityTypes.playAndShareSounds, perform: { _ in
                        tabSelection.wrappedValue = .sounds
                    })
                    //                .onContinueUserActivity(Shared.ActivityTypes.viewCollections, perform: { _ in
                    //                    tabSelection = .collections
                    //                })
                    //                .onContinueUserActivity(Shared.ActivityTypes.playAndShareSongs, perform: { _ in
                    //                    tabSelection = .songs
                    //                })
                    .onContinueUserActivity(Shared.ActivityTypes.viewLast24HoursTopChart, perform: { _ in
                        tabSelection.wrappedValue = .trends
                        trendsHelper.timeIntervalToGoTo = .last24Hours
                    })
                    .onContinueUserActivity(Shared.ActivityTypes.viewLastWeekTopChart, perform: { _ in
                        tabSelection.wrappedValue = .trends
                        trendsHelper.timeIntervalToGoTo = .lastWeek
                    })
                    .onContinueUserActivity(Shared.ActivityTypes.viewLastMonthTopChart, perform: { _ in
                        tabSelection.wrappedValue = .trends
                        trendsHelper.timeIntervalToGoTo = .lastMonth
                    })
                    .onContinueUserActivity(Shared.ActivityTypes.viewAllTimeTopChart, perform: { _ in
                        tabSelection.wrappedValue = .trends
                        trendsHelper.timeIntervalToGoTo = .allTime
                    })
                }
            } else {
                TabView {
                    Tab(Shared.TabInfo.name(.allSounds), systemImage: Shared.TabInfo.symbol(.allSounds)) {
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
                                userFolderRepository: userFolderRepository,
                                bannerRepository: BannerRepository(),
                                searchService: searchService,
                                analyticsService: AnalyticsService()
                            )
                            .environment(trendsHelper)
                            .environment(settingsHelper)
                            .navigationDestination(for: GeneralNavigationDestination.self) { screen in
                                GeneralRouter(destination: screen, contentRepository: contentRepository)
                            }
                        }
                        .environment(\.push, PushAction { soundsPath.append($0) })
                    }

                    Tab(Shared.TabInfo.name(.favorites), systemImage: Shared.TabInfo.symbol(.favorites)) {
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

                    Tab(Shared.TabInfo.name(PadScreen.reactions), systemImage: Shared.TabInfo.symbol(PadScreen.reactions)) {
                        NavigationStack(path: $reactionsPath) {
                            ReactionsView()
                                .environment(trendsHelper)
                                .navigationDestination(for: GeneralNavigationDestination.self) { screen in
                                    GeneralRouter(destination: screen, contentRepository: contentRepository)
                                }
                        }
                        .environment(\.push, PushAction { reactionsPath.append($0) })
                    }

                    Tab(Shared.TabInfo.name(.groupedByAuthor), systemImage: Shared.TabInfo.symbol(.groupedByAuthor)) {
                        NavigationStack(path: $authorsPath) {
                            StandaloneAuthorsView()
                                .navigationDestination(for: GeneralNavigationDestination.self) { screen in
                                    GeneralRouter(destination: screen, contentRepository: contentRepository)
                                }
                        }
                        .environment(\.push, PushAction { authorsPath.append($0) })
                    }

                    if FeatureFlag.isEnabled(.episodes) {
                        Tab("Episódios", systemImage: "radio") {
                            NavigationStack(path: $episodesPath) {
                                EpisodesView()
                                    .navigationDestination(for: PodcastEpisode.self) { episode in
                                        EpisodeDetailView(episode: episode)
                                    }
                            }
                            .environment(\.push, PushAction { episodesPath.append($0) })
                        }
                    } else {
                        Tab(Shared.TabInfo.name(PadScreen.trends), systemImage: Shared.TabInfo.symbol(PadScreen.trends)) {
                            NavigationStack {
                                TrendsView(
                                    audienceViewModel: MostSharedByAudienceView.ViewModel(trendsService: trendsService),
                                    tabSelection: tabSelection,
                                    activePadScreen: .constant(.trends)
                                )
                                .environment(trendsHelper)
                            }
                        }
                    }

                    TabSection("Minhas Pastas") {
                        Tab(Shared.TabInfo.name(.allFolders), systemImage: Shared.TabInfo.symbol(.allFolders)) {
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

                        switch sidebarFoldersViewModel.state {
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

                    Tab(role: .search) {
                        NavigationStack(path: $searchTabPath) {
                            StandaloneSearchView(
                                searchService: searchService,
                                trendsService: trendsService,
                                contentRepository: contentRepository,
                                userFolderRepository: userFolderRepository,
                                analyticsService: AnalyticsService()
                            )
                            .navigationDestination(for: GeneralNavigationDestination.self) { screen in
                                GeneralRouter(destination: screen, contentRepository: contentRepository)
                            }
                        }
                        .environment(\.push, PushAction { searchTabPath.append($0) })
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
                        await sidebarFoldersViewModel.onViewAppeared()
                    }
                }
            }
        }
        .environment(syncValues)
        .environment(episodePlayer)
        .environment(episodeFavoritesStore)
        .environment(episodeProgressStore)
        .environment(episodePlayedStore)
        .environment(episodeBookmarkStore)
        .onChange(of: episodePlayer.pendingRemoteBookmark) { _, isPending in
            guard isPending else { return }
            showNowPlaying = true
        }
        .onAppear {
            episodePlayer.progressStore = episodeProgressStore
            episodePlayer.bookmarkStore = episodeBookmarkStore
            print("MAIN VIEW - ON APPEAR")
            sendUserPersonalTrendsToServerIfEnabled()
            displayOnboardingIfNeeded()
            displayUniversalSearchWhatsNewIfNeeded()

            Task {
//                if AppPersistentMemory.shared.hasAllowedContentUpdate() {
//                    await contentUpdateService.update()
//                }
                await sendFolderResearchChanges()
            }
        }
        .sheet(isPresented: $showingModalView) {
            switch subviewToOpen {
            case .settings:
                SettingsView(apiClient: APIClient.shared)
                    .environment(settingsHelper)

            case .onboarding:
                OnboardingView()
                    .interactiveDismissDisabled(UIDevice.isiPhone)

            case .retrospective, .whatsNew:
                EmptyView()
            }
        }
        .sheet(item: $folderForEditing) { folder in
            FolderInfoEditingView(
                folder: folder,
                folderRepository: userFolderRepository,
                dismissSheet: {
                    folderForEditing = nil
                    updateFolderList = true
                }
            )
        }
        // Could be removed in the future, but for now using `showingModalView` bugs out on iPad. Shows Onboarding most of the time.
        .sheet(isPresented: $isShowingSettingsSheet) {
            SettingsView(apiClient: APIClient.shared)
                .environment(settingsHelper)
        }
        .sheet(isPresented: $showUniversalSearchWhatsNew) {
            IntroducingUniversalSearchView(appMemory: AppPersistentMemory.shared)
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

            let todayDate = Date.now.onlyDate ?? Date.now

            if let lastDate = AppPersistentMemory.shared.getLastSendDateOfUserPersonalTrendsToServer(),
               let lastOnlyDate = lastDate.onlyDate {
                if lastOnlyDate < todayDate {
                    let result = await Podium.shared.sendShareCountStatsToServer()

                    guard result == .successful || result == .noStatsToSend else {
                        return
                    }
                    AppPersistentMemory.shared.setLastSendDateOfUserPersonalTrendsToServer(to: todayDate)
                }
            } else {
                let result = await Podium.shared.sendShareCountStatsToServer()

                guard result == .successful || result == .noStatsToSend else {
                    return
                }
                AppPersistentMemory.shared.setLastSendDateOfUserPersonalTrendsToServer(to: todayDate)
            }
        }
    }

    private func displayOnboardingIfNeeded() {
        if !AppPersistentMemory.shared.hasShownNotificationsOnboarding() {
            subviewToOpen = .onboarding
            showingModalView = true
        }
    }

    private func displayUniversalSearchWhatsNewIfNeeded() {
        // Don't show if onboarding is being shown
        guard AppPersistentMemory.shared.hasShownNotificationsOnboarding() else { return }
        // Don't show if already seen
        guard !AppPersistentMemory.shared.hasSeenUniversalSearchWhatsNewScreen() else { return }

        showUniversalSearchWhatsNew = true
    }

    private func sendFolderResearchChanges() async {
        do {
            let provider = FolderResearchProvider(
                userSettings: UserSettings(),
                appMemory: AppPersistentMemory.shared,
                localDatabase: LocalDatabase.shared,
                repository: FolderResearchRepository()
            )
            try await provider.sendChanges()
        } catch {
            await AnalyticsService().send(
                originatingScreen: "MainView",
                action: "issueSendingFolderResearchChanges(\(error.localizedDescription))"
            )
        }
    }
}

// MARK: - Preview

#Preview {
    MainView(
        tabSelection: .constant(.sounds),
        padSelection: .constant(.allSounds)
    )
    .environment(EpisodePlayer())
}

