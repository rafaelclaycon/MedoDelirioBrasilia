//
//  MainSoundContainer.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 13/04/24.
//

import SwiftUI

struct MainSoundContainer: View {

    @StateObject private var viewModel: MainSoundContainerViewModel
    @StateObject private var allSoundsViewModel: SoundListViewModel<Sound>
    @StateObject private var favoritesViewModel: SoundListViewModel<Sound>
    private var currentSoundsListMode: Binding<SoundsListMode>
    private var showSettings: Binding<Bool>

    @State private var subviewToOpen: MainSoundContainerModalToOpen = .syncInfo
    @State private var showingModalView = false
    @State private var stopShowingFloatingSelector: Bool? = false

    // Folders
    @StateObject var deleteFolderAide = DeleteFolderViewAideiPhone()

    // May be dropped
    @State private var authorSortOption: Int = 0
    @State private var soundSortOption: Int = 0

    // Authors
    @State var authorSortAction: AuthorSortOption = .nameAscending
    @State var authorSearchText: String = .empty

    // Sync
    @State private var shouldDisplayYoureOfflineBanner: Bool = true
    @State private var displayLongUpdateBanner: Bool = false

    // Temporary banners
    @State private var shouldDisplayRecurringDonationBanner: Bool = false

    // MARK: - Environment Objects

    @EnvironmentObject var trendsHelper: TrendsHelper
    @EnvironmentObject var settingsHelper: SettingsHelper
    @EnvironmentObject var networkMonitor: NetworkMonitor

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
            return !(stopShowingFloatingSelector ?? false)
        }
    }

    // MARK: - Initializer

    init(
        viewModel: MainSoundContainerViewModel,
        currentSoundsListMode: Binding<SoundsListMode>,
        showSettings: Binding<Bool>
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._allSoundsViewModel = StateObject(wrappedValue: SoundListViewModel<Sound>(
            data: viewModel.allSoundsPublisher,
            menuOptions: [.sharingOptions(), .organizingOptions(), .detailsOptions()],
            currentSoundsListMode: currentSoundsListMode
        ))
        self._favoritesViewModel = StateObject(wrappedValue: SoundListViewModel<Sound>(
            data: viewModel.favoritesPublisher,
            menuOptions: [.sharingOptions(), .organizingOptions(), .detailsOptions()],
            currentSoundsListMode: currentSoundsListMode,
            needsRefreshAfterChange: true,
            refreshAction: { viewModel.reloadFavorites() }
        ))
        self.currentSoundsListMode = currentSoundsListMode
        self.showSettings = showSettings
    }

    // MARK: - Body

    var body: some View {
        VStack {
            switch viewModel.currentViewMode {
            case .allSounds:
                SoundList(
                    viewModel: allSoundsViewModel,
                    stopShowingFloatingSelector: $stopShowingFloatingSelector,
                    allowSearch: true,
                    allowRefresh: true,
                    showSoundCountAtTheBottom: true,
                    showExplicitDisabledWarning: true,
                    syncAction: {
                        Task { // Keep this Task to avoid "cancelled" issue.
                            await viewModel.sync(lastAttempt: AppPersistentMemory.getLastUpdateAttempt())
                        }
                    },
                    emptyStateView: AnyView(
                        Text("Nenhum som a ser exibido. Isso é esquisito.")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 20)
                    ),
                    headerView: AnyView(
                        VStack {
                            if !networkMonitor.isConnected, shouldDisplayYoureOfflineBanner {
                                YoureOfflineView(isBeingShown: $shouldDisplayYoureOfflineBanner)
                            }

                            if displayLongUpdateBanner {
                                LongUpdateBanner(
                                    completedNumber: $viewModel.processedUpdateNumber,
                                    totalUpdateCount: $viewModel.totalUpdateCount
                                )
                                .padding(.horizontal, 10)
                            }

//                            if shouldDisplayRecurringDonationBanner, viewModel.searchText.isEmpty {
//                                RecurringDonationBanner(isBeingShown: $shouldDisplayRecurringDonationBanner)
//                                    .padding(.horizontal, 10)
//                            }
                        }
                    )
                )

            case .favorites:
                SoundList(
                    viewModel: favoritesViewModel,
                    stopShowingFloatingSelector: $stopShowingFloatingSelector,
                    allowSearch: true,
                    emptyStateView: AnyView(
                        NoFavoritesView()
                            .padding(.horizontal, 25)
                            .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? 100 : 15)
                    )
                )

            case .folders:
                MyFoldersiPhoneView()
                    .environmentObject(deleteFolderAide)
                
            case .byAuthor:
                AuthorsView(
                    sortOption: $authorSortOption,
                    sortAction: $authorSortAction,
                    searchTextForControl: $authorSearchText
                )
            }
        }
        .navigationTitle(Text(title))
        .navigationBarItems(
            leading: leadingToolbarControls(),
            trailing: trailingToolbarControls()
        )
        .onChange(of: viewModel.processedUpdateNumber) { _ in
            withAnimation {
                displayLongUpdateBanner = viewModel.totalUpdateCount >= 10 && viewModel.processedUpdateNumber != viewModel.totalUpdateCount
            }
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
            viewModel.reloadAllSounds()
            viewModel.reloadFavorites()
        }
        .oneTimeTask {
            print("MAIN SOUND CONTAINER - ONE TIME TASK")
            if viewModel.currentViewMode == .allSounds {
                await viewModel.sync(lastAttempt: AppPersistentMemory.getLastUpdateAttempt())
            }
        }
    }

    // MARK: - Auxiliary Views

    @ViewBuilder func leadingToolbarControls() -> some View {
        if currentSoundsListMode.wrappedValue == .selection {
            Button {
                if viewModel.currentViewMode == .allSounds {
                    allSoundsViewModel.stopSelecting()
                } else {
                    favoritesViewModel.stopSelecting()
                }
            } label: {
                Text("Cancelar")
                    .bold()
            }
        } else {
            if UIDevice.isiPhone {
                Button {
                    showSettings.wrappedValue = true
                } label: {
                    Image(systemName: "gearshape")
                }
            } else {
                EmptyView()
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
                            Picker("Ordenação de Autores", selection: $authorSortOption) {
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
                    .onChange(of: authorSortOption, perform: { authorSortOption in
                        authorSortAction = AuthorSortOption(rawValue: authorSortOption) ?? .nameAscending
                    })
                } else {
                    if currentSoundsListMode.wrappedValue == .regular {
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
                            }//.disabled(viewModel.currentViewMode == .favorites && viewModel.sounds.count == 0)
                        }

                        Section {
                            Picker("Ordenação de Sons", selection: $soundSortOption) {
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

                                if CommandLine.arguments.contains("-UNDER_DEVELOPMENT") {
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
//                    .onChange(of: viewModel.soundSortOption) {
//                        viewModel.sortSounds(by: SoundSortOption(rawValue: $0) ?? .dateAddedDescending)
//                        UserSettings.setSoundSortOption(to: $0)
//                    }
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
        .onChange(of: viewModel.currentViewMode) {
            if $0 == .favorites {
                viewModel.reloadFavorites()
            }
        }
        //.disabled(isLoadingSounds && viewModel.currentViewMode == .allSounds)
    }

    // MARK: - Functions

    private func selectionNavBarTitle(for viewModel: SoundListViewModel<Sound>) -> String {
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
        showSettings: .constant(false)
    )
}
