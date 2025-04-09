//
//  MainContentContainerView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 13/04/24.
//

import SwiftUI

/// Main view of the app on iPhone. This is reponsible for showing the main content view and start content sync.
struct MainContentContainerView: View {

    @StateObject private var viewModel: MainSoundContainerViewModel
    @StateObject private var allSoundsViewModel: ContentListViewModel<[AnyEquatableMedoContent]>
    private var currentSoundsListMode: Binding<SoundsListMode>
    private let openSettingsAction: () -> Void

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
    @State private var showRetroBanner: Bool = false
    @State private var showClassicRetroView: Bool = false

    // MARK: - Environment Objects

    @Environment(TrendsHelper.self) private var trendsHelper
    @EnvironmentObject var settingsHelper: SettingsHelper
    @EnvironmentObject var playRandomSoundHelper: PlayRandomSoundHelper

    // MARK: - Computed Properties

    private var title: String {
        guard currentSoundsListMode.wrappedValue == .regular else {
            return selectionNavBarTitle(for: allSoundsViewModel)
        }
        return "Sons"
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

    // MARK: - Shared Environment

    @Environment(\.scenePhase) var scenePhase

    // MARK: - Initializer

    init(
        viewModel: MainSoundContainerViewModel,
        currentSoundsListMode: Binding<SoundsListMode>,
        openSettingsAction: @escaping () -> Void
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._allSoundsViewModel = StateObject(wrappedValue: ContentListViewModel<[AnyEquatableMedoContent]>(
            data: viewModel.allContentPublisher,
            menuOptions: [.sharingOptions(), .organizingOptions(), .detailsOptions()],
            currentSoundsListMode: currentSoundsListMode
        ))
        self.currentSoundsListMode = currentSoundsListMode
        self.openSettingsAction = openSettingsAction
    }

    // MARK: - View Body

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                TopSelector(selected: $viewModel.currentViewMode)

                switch viewModel.currentViewMode {
                case .all, .favorites, .songs:
                    ContentList(
                        viewModel: allSoundsViewModel,
                        soundSearchTextIsEmpty: $soundSearchTextIsEmpty,
                        showSoundCountAtTheBottom: viewModel.currentViewMode == .all,
                        showExplicitDisabledWarning: viewModel.currentViewMode == .all,
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
                            VStack {
                                if viewModel.currentViewMode == .favorites {
                                    NoFavoritesView()
                                        .padding(.horizontal, 25)
                                        .padding(.vertical, 50)
                                } else {
                                    Text("Nenhum som a ser exibido. Isso é esquisito.")
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 20)
                                }
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
                    cancelAction: { allSoundsViewModel.onExitMultiSelectModeSelected() },
                    openSettingsAction: openSettingsAction
                ),
                trailing: trailingToolbarControls()
            )
            .onChange(of: viewModel.currentViewMode) {
                viewModel.onSelectedViewModeChanged(favorites: allSoundsViewModel.favoritesKeeper)
            }
            .onChange(of: viewModel.processedUpdateNumber) {
                withAnimation {
                    displayLongUpdateBanner = viewModel.totalUpdateCount >= 10 && viewModel.processedUpdateNumber != viewModel.totalUpdateCount
                }
            }
            .onChange(of: playRandomSoundHelper.soundIdToPlay) {
                if !playRandomSoundHelper.soundIdToPlay.isEmpty {
                    viewModel.currentViewMode = .all
                    allSoundsViewModel.scrollAndPlaySound(withId: playRandomSoundHelper.soundIdToPlay)
                    playRandomSoundHelper.soundIdToPlay = ""
                }
            }
            .sheet(isPresented: $showingModalView) {
                SyncInfoView(
                    lastUpdateAttempt: AppPersistentMemory().getLastUpdateAttempt(),
                    lastUpdateDate: LocalDatabase.shared.dateTimeOfLastUpdate()
                )
            }
    //        .sheet(isPresented: $showClassicRetroView) {
    //            ClassicRetroView(
    //                imageSaveSucceededAction: { exportAnalytics in
    //                    allSoundsViewModel.displayToast(
    //                        toastText: Shared.Retro.successMessage,
    //                        displayTime: .seconds(5)
    //                    )
    //
    //                    Analytics().send(
    //                        originatingScreen: "MainContentContainerView",
    //                        action: "didExportRetro2024Images(\(exportAnalytics))"
    //                    )
    //                }
    //            )
    //        }
            .onReceive(settingsHelper.$updateSoundsList) { shouldUpdate in // iPad - Settings explicit toggle.
                if shouldUpdate {
                    viewModel.onExplicitContentSettingChanged()
                    settingsHelper.updateSoundsList = false
                }
            }
            .onChange(of: trendsHelper.notifyMainSoundContainer) {
                highlight(soundId: trendsHelper.notifyMainSoundContainer)
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
                        .padding(.bottom, Shared.Constants.toastViewBottomPaddingPad)
                    }
                    .transition(.moveAndFade)
                }
            }
            .onAppear {
                viewModel.onViewDidAppear()
            }
            .onChange(of: scenePhase) {
                Task {
                    await viewModel.onScenePhaseChanged(newPhase: scenePhase)
                }
            }
        }
        .refreshable {
            Task { // Keep this Task to avoid "cancelled" issue.
                await viewModel.onSyncRequested()
            }
        }
    }
}

// MARK: - Subviews

extension MainContentContainerView {

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

    @ViewBuilder
    func trailingToolbarControls() -> some View {
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
                    .onChange(of: viewModel.authorSortOption) {
                        authorSortAction = AuthorSortOption(rawValue: viewModel.authorSortOption) ?? .nameAscending
                        UserSettings().saveAuthorSortOption(viewModel.authorSortOption)
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
                                allSoundsViewModel.onEnterMultiSelectModeSelected()
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
                    .onChange(of: viewModel.soundSortOption) {
                        viewModel.onSoundSortOptionChanged()
                    }
                    .disabled(
                        viewModel.currentViewMode == .favorites //&& viewModel.favorites?.count == 0 // TODO: Do we need to adapt this?
                    )
                }
            }
        }
    }
}

// MARK: - Functions

extension MainContentContainerView {

    private func selectionNavBarTitle(for viewModel: ContentListViewModel<[AnyEquatableMedoContent]>) -> String {
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
        viewModel.currentViewMode = .all
        allSoundsViewModel.cancelSearchAndHighlight(id: soundId)
        trendsHelper.notifyMainSoundContainer = ""
        trendsHelper.soundIdToGoTo = soundId
    }
}

// MARK: - Preview

#Preview {
    MainContentContainerView(
        viewModel: .init(
            currentViewMode: .all,
            soundSortOption: SoundSortOption.dateAddedDescending.rawValue,
            authorSortOption: AuthorSortOption.nameAscending.rawValue,
            currentSoundsListMode: .constant(.regular),
            syncValues: SyncValues()
        ),
        currentSoundsListMode: .constant(.regular),
        openSettingsAction: {}
    )
}
