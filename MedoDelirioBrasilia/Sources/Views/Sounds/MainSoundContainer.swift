//
//  MainSoundContainer.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 13/04/24.
//

import SwiftUI

struct MainSoundContainer: View {

    @StateObject private var viewModel: MainSoundContainerViewModel
    @StateObject private var allSoundsViewModel: SoundListViewModel<[Sound]>
    @StateObject private var favoritesViewModel: SoundListViewModel<[Sound]>
    private var currentSoundsListMode: Binding<SoundsListMode>
    private let openSettingsAction: () -> Void
    private let showRetrospectiveAction: () -> Void

    @State private var subviewToOpen: MainSoundContainerModalToOpen = .syncInfo
    @State private var showingModalView = false
    @State private var soundSearchTextIsEmpty: Bool? = true

    // Folders
    @StateObject var deleteFolderAide = DeleteFolderViewAide()

    // Authors
    @State var authorSortAction: AuthorSortOption = .nameAscending
    @State var authorSearchText: String = .empty

    // Sync
    @State private var displayLongUpdateBanner: Bool = false

    // Temporary banners
    @State private var shouldDisplayRecurringDonationBanner: Bool = false

    // Retro 2024
    @State private var showRetroBanner: Bool = true
    @State private var showRetroModalView = false

    // MARK: - Environment Objects

    @EnvironmentObject var trendsHelper: TrendsHelper
    @EnvironmentObject var settingsHelper: SettingsHelper
    @EnvironmentObject var playRandomSoundHelper: PlayRandomSoundHelper

    // MARK: - Computed Properties

    private var title: String {
        guard currentSoundsListMode.wrappedValue == .regular else {
            return selectionNavBarTitle(
                for: viewModel.currentViewMode == .allSounds ? allSoundsViewModel : favoritesViewModel
            )
        }
        switch viewModel.currentViewMode {
        case .allSounds:
            return "Sons"
        case .favorites:
            return "Favoritos"
        case .folders:
            return "Minhas Pastas"
        case .byAuthor:
            return "Autores"
        }
    }

    private var displayFloatingSelectorView: Bool {
        guard UIDevice.current.userInterfaceIdiom == .phone else { return false }
        guard currentSoundsListMode.wrappedValue == .regular else { return false }
        if viewModel.currentViewMode == .byAuthor {
            return authorSearchText.isEmpty
        } else {
            return soundSearchTextIsEmpty ?? false
        }
    }

    // MARK: - Initializer

    init(
        viewModel: MainSoundContainerViewModel,
        currentSoundsListMode: Binding<SoundsListMode>,
        openSettingsAction: @escaping () -> Void,
        showRetrospectiveAction: @escaping () -> Void
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._allSoundsViewModel = StateObject(wrappedValue: SoundListViewModel<[Sound]>(
            data: viewModel.allSoundsPublisher,
            menuOptions: [.sharingOptions(), .organizingOptions(), .detailsOptions()],
            currentSoundsListMode: currentSoundsListMode
        ))
        self._favoritesViewModel = StateObject(wrappedValue: SoundListViewModel<[Sound]>(
            data: viewModel.favoritesPublisher,
            menuOptions: [.sharingOptions(), .organizingOptions(), .detailsOptions()],
            currentSoundsListMode: currentSoundsListMode,
            needsRefreshAfterChange: true,
            refreshAction: { viewModel.reloadFavorites() }
        ))
        self.currentSoundsListMode = currentSoundsListMode
        self.openSettingsAction = openSettingsAction
        self.showRetrospectiveAction = showRetrospectiveAction
    }

    // MARK: - View Body

    var body: some View {
        VStack {
            switch viewModel.currentViewMode {
            case .allSounds:
                SoundList(
                    viewModel: allSoundsViewModel,
                    soundSearchTextIsEmpty: $soundSearchTextIsEmpty,
                    allowSearch: true,
                    allowRefresh: true,
                    showSoundCountAtTheBottom: true,
                    showExplicitDisabledWarning: true,
                    syncAction: {
                        Task { // Keep this Task to avoid "cancelled" issue.
                            await viewModel.sync(lastAttempt: AppPersistentMemory().getLastUpdateAttempt())
                        }
                    },
                    dataLoadingDidFail: viewModel.dataLoadingDidFail,
                    headerView: {
                        VStack {
                            if displayLongUpdateBanner {
                                LongUpdateBanner(
                                    completedNumber: $viewModel.processedUpdateNumber,
                                    totalUpdateCount: $viewModel.totalUpdateCount
                                )
                                .padding(.horizontal, 10)
                            }

                            if showRetroBanner {
                                Retro2024Banner(
                                    openStoriesAction: { showRetrospectiveAction() }
                                )
                                .padding(.horizontal, 10)
                            }

//                            if shouldDisplayRecurringDonationBanner, viewModel.searchText.isEmpty {
//                                RecurringDonationBanner(
//                                    isBeingShown: $shouldDisplayRecurringDonationBanner
//                                )
//                                .padding(.horizontal, 10)
//                            }
                        }
                    },
                    loadingView:
                        VStack {
                            HStack(spacing: 10) {
                                ProgressView()

                                Text("Carregando sons...")
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    ,
                    emptyStateView:
                        Text("Nenhum som a ser exibido. Isso é esquisito.")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 20)
                    ,
                    errorView:
                        VStack {
                            HStack(spacing: 10) {
                                ProgressView()

                                Text("Erro ao carregar sons.")
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                        }
                )

            case .favorites:
                SoundList<EmptyView, VStack, VStack, VStack>(
                    viewModel: favoritesViewModel,
                    soundSearchTextIsEmpty: $soundSearchTextIsEmpty,
                    allowSearch: true,
                    dataLoadingDidFail: viewModel.dataLoadingDidFail,
                    loadingView:
                        VStack {
                            HStack(spacing: 10) {
                                ProgressView()

                                Text("Carregando sons...")
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    ,
                    emptyStateView:
                        VStack {
                            NoFavoritesView()
                                .padding(.horizontal, 25)
                                .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? 100 : 15)
                        }
                    ,
                    errorView:
                        VStack {
                            HStack(spacing: 10) {
                                ProgressView()

                                Text("Erro ao carregar sons.")
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                        }
                )

            case .folders:
                MyFoldersiPhoneView()
                    .environmentObject(deleteFolderAide)
                
            case .byAuthor:
                AuthorsView(
                    sortOption: $viewModel.authorSortOption,
                    sortAction: $authorSortAction,
                    searchTextForControl: $authorSearchText
                )
            }
        }
        .navigationTitle(Text(title))
        .navigationBarItems(
            leading: LeadingToolbarControls(
                isSelecting: currentSoundsListMode.wrappedValue == .selection,
                cancelAction: {
                    if viewModel.currentViewMode == .allSounds {
                        allSoundsViewModel.stopSelecting()
                    } else {
                        favoritesViewModel.stopSelecting()
                    }
                },
                openSettingsAction: openSettingsAction
            ),
            trailing: trailingToolbarControls()
        )
        .onChange(of: viewModel.processedUpdateNumber) { _ in
            withAnimation {
                displayLongUpdateBanner = viewModel.totalUpdateCount >= 10 && viewModel.processedUpdateNumber != viewModel.totalUpdateCount
            }
        }
        .onChange(of: playRandomSoundHelper.soundIdToPlay) { soundId in
            if !soundId.isEmpty {
                viewModel.currentViewMode = .allSounds
                allSoundsViewModel.scrollAndPlaySound(withId: soundId)
                playRandomSoundHelper.soundIdToPlay = ""
            }
        }
        .sheet(isPresented: $showingModalView) {
            SyncInfoView(
                lastUpdateAttempt: AppPersistentMemory().getLastUpdateAttempt(),
                lastUpdateDate: LocalDatabase.shared.dateTimeOfLastUpdate()
            )
        }
        .fullScreenCover(isPresented: $showRetroModalView) {
            StoriesView()
        }
        .onReceive(settingsHelper.$updateSoundsList) { shouldUpdate in // iPad - Settings explicit toggle.
            if shouldUpdate {
                viewModel.reloadAllSounds()
                settingsHelper.updateSoundsList = false
            }
        }
        .onReceive(trendsHelper.$soundIdToGoTo) {
            highlight(soundId: $0)
        }
        .overlay {
            ZStack {
                if displayFloatingSelectorView {
                    VStack {
                        Spacer()
                        floatingSelectorView()
                            .padding()
                    }
                }

                if viewModel.showToastView {
                    VStack {
                        Spacer()

                        ToastView(
                            icon: viewModel.toastIcon,
                            iconColor: viewModel.toastIconColor,
                            text: viewModel.toastText
                        )
                        .padding(.horizontal)
                        .padding(
                            .bottom,
                            UIDevice.isiPhone ? Shared.Constants.toastViewBottomPaddingPhone : Shared.Constants.toastViewBottomPaddingPad
                        )
                    }
                    .transition(.moveAndFade)
                }
            }
        }
        .onAppear {
            print("MAIN SOUND CONTAINER - ON APPEAR")

            if !viewModel.firstRunSyncHappened {
                Task {
                    print("WILL START SYNCING")
                    await viewModel.sync(lastAttempt: AppPersistentMemory().getLastUpdateAttempt())
                    print("DID FINISH SYNCING")
                }
            }

            viewModel.reloadAllSounds()
            viewModel.reloadFavorites()
            favoritesViewModel.loadFavorites()
        }
    }
}

// MARK: - Subviews

extension MainSoundContainer {

    struct LeadingToolbarControls: View {

        let isSelecting: Bool
        let cancelAction: () -> Void
        let openSettingsAction: () -> Void

        var body: some View {
            if isSelecting {
                Button {
                    cancelAction()
                } label: {
                    Text("Cancelar")
                        .bold()
                }
            } else {
                if UIDevice.isiPhone {
                    Button {
                        openSettingsAction()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                } else {
                    EmptyView()
                }
            }
        }
    }

    @ViewBuilder func trailingToolbarControls() -> some View {
        if viewModel.currentViewMode == .folders {
            EmptyView()
        } else {
            HStack(spacing: 15) {
                if viewModel.currentViewMode == .byAuthor {
                    Menu {
                        Section {
                            Picker("Ordenação de Autores", selection: $viewModel.authorSortOption) {
                                Text("Nome")
                                    .tag(0)

                                Text("Autores com Mais Sons no Topo")
                                    .tag(1)

                                Text("Autores com Menos Sons no Topo")
                                    .tag(2)
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                    .onChange(of: viewModel.authorSortOption) { authorSortOption in
                        authorSortAction = AuthorSortOption(rawValue: authorSortOption) ?? .nameAscending
                        UserSettings().saveAuthorSortOption(authorSortOption)
                    }
                } else {
                    if UIDevice.isiPhone && currentSoundsListMode.wrappedValue == .regular {
                        SyncStatusView()
                            .onTapGesture {
                                subviewToOpen = .syncInfo
                                showingModalView = true
                            }
                    } else if !UIDevice.isiPhone && viewModel.currentViewMode != .favorites {
                        SyncStatusView()
                            .onTapGesture {
                                subviewToOpen = .syncInfo
                                showingModalView = true
                            }
                    }

                    Menu {
                        Section {
                            Button {
                                if viewModel.currentViewMode == .allSounds {
                                    allSoundsViewModel.startSelecting()
                                } else {
                                    favoritesViewModel.startSelecting()
                                }
                            } label: {
                                Label(
                                    currentSoundsListMode.wrappedValue == .selection ? "Cancelar Seleção" : "Selecionar",
                                    systemImage: currentSoundsListMode.wrappedValue == .selection ? "xmark.circle" : "checkmark.circle"
                                )
                            }
                        }

                        Section {
                            Picker("Ordenação de Sons", selection: $viewModel.soundSortOption) {
                                Text("Título")
                                    .tag(0)

                                Text("Nome do(a) Autor(a)")
                                    .tag(1)

                                Text("Mais Recentes no Topo")
                                    .tag(2)

                                Text("Mais Curtos no Topo")
                                    .tag(3)

                                Text("Mais Longos no Topo")
                                    .tag(4)

                                if CommandLine.arguments.contains("-SHOW_MORE_DEV_OPTIONS") {
                                    Text("Título Mais Longo no Topo")
                                        .tag(5)

                                    Text("Título Mais Curto no Topo")
                                        .tag(6)
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .onChange(of: viewModel.soundSortOption) { sortOption in
                        viewModel.sortSounds(by: sortOption)
                    }
                    .disabled(
                        viewModel.currentViewMode == .favorites && viewModel.favorites?.count == 0
                    )
                }
            }
        }
    }

    @ViewBuilder func floatingSelectorView() -> some View {
        Picker("Exibição", selection: $viewModel.currentViewMode) {
            Text("Todos")
                .tag(SoundsViewMode.allSounds)

            Text("Favoritos")
                .tag(SoundsViewMode.favorites)

            Text("Pastas")
                .tag(SoundsViewMode.folders)

            Text("Por Autor")
                .tag(SoundsViewMode.byAuthor)
        }
        .pickerStyle(.segmented)
        .background(.regularMaterial)
        .cornerRadius(8)
        .onChange(of: viewModel.currentViewMode) { newMode in
            if newMode == .allSounds {
                allSoundsViewModel.loadFavorites()
            } else if newMode == .favorites {
                // Similar names, different functions.
                viewModel.reloadFavorites() // This changes SoundList's data source, effectively changing what tiles are shown.
                favoritesViewModel.loadFavorites() // This changes favoritesKeeper, the thing responsible for painting each tile differently.
            }
        }
        //.disabled(isLoadingSounds && viewModel.currentViewMode == .allSounds)
    }
}

// MARK: - Functions

extension MainSoundContainer {

    private func selectionNavBarTitle(for viewModel: SoundListViewModel<[Sound]>) -> String {
        if viewModel.selectionKeeper.count == 0 {
            return Shared.SoundSelection.selectSounds
        }
        if viewModel.selectionKeeper.count == 1 {
            return Shared.SoundSelection.soundSelectedSingular
        }
        return String(format: Shared.SoundSelection.soundsSelectedPlural, viewModel.selectionKeeper.count)
    }

    private func highlight(soundId: String) {
        guard !soundId.isEmpty else { return }
        viewModel.currentViewMode = .allSounds
        allSoundsViewModel.cancelSearchAndHighlight(id: soundId)
        trendsHelper.soundIdToGoTo = ""
        trendsHelper.youCanScrollNow = soundId
    }
}

#Preview {
    MainSoundContainer(
        viewModel: .init(
            currentViewMode: .allSounds,
            soundSortOption: SoundSortOption.dateAddedDescending.rawValue,
            authorSortOption: AuthorSortOption.nameAscending.rawValue,
            currentSoundsListMode: .constant(.regular),
            syncValues: SyncValues()
        ),
        currentSoundsListMode: .constant(.regular),
        openSettingsAction: {},
        showRetrospectiveAction: {}
    )
}
