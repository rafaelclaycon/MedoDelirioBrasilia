//
//  MainContentContainerView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 13/04/24.
//

import SwiftUI

/// Main view of the app on iPhone. This is reponsible for showing the main content view and start content sync.
struct MainContentView: View {

    @StateObject private var viewModel: MainContentViewModel
    @StateObject private var allSoundsViewModel: ContentGridViewModel<[AnyEquatableMedoContent]>
    private var currentContentListMode: Binding<ContentListMode>
    private let openSettingsAction: () -> Void

    @State private var subviewToOpen: MainSoundContainerModalToOpen = .syncInfo
    @State private var showingModalView = false
    @State private var contentSearchTextIsEmpty: Bool? = true

    // Folders
    @StateObject var deleteFolderAide = DeleteFolderViewAide()

    // Authors
    @State var authorSortAction: AuthorSortOption = .nameAscending
    @State var authorSearchText: String = .empty

    // Sync
    @State private var displayLongUpdateBanner: Bool = false

    // Temporary banners
    @State private var shouldDisplayRecurringDonationBanner: Bool = false

    @ScaledMetric private var explicitOffWarningTopPadding = 16
    @ScaledMetric private var explicitOffWarningBottomPadding = 20

    // MARK: - Environment Objects

    @Environment(TrendsHelper.self) private var trendsHelper
    @EnvironmentObject var settingsHelper: SettingsHelper
    @EnvironmentObject var playRandomSoundHelper: PlayRandomSoundHelper

    // MARK: - Computed Properties

    private var title: String {
        guard currentContentListMode.wrappedValue == .regular else {
            return selectionNavBarTitle(for: allSoundsViewModel)
        }
        return "Sons"
    }

    // MARK: - Shared Environment

    @Environment(\.scenePhase) var scenePhase

    // MARK: - Initializer

    init(
        viewModel: MainContentViewModel,
        currentContentListMode: Binding<ContentListMode>,
        toast: Binding<Toast?>,
        openSettingsAction: @escaping () -> Void
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._allSoundsViewModel = StateObject(wrappedValue: ContentGridViewModel<[AnyEquatableMedoContent]>(
            data: viewModel.allContentPublisher,
            menuOptions: [.sharingOptions(), .organizingOptions(), .detailsOptions()],
            currentListMode: currentContentListMode,
            toast: toast
        ))
        self.currentContentListMode = currentContentListMode
        self.openSettingsAction = openSettingsAction
    }

    // MARK: - View Body

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: .zero) {
                    if contentSearchTextIsEmpty ?? true {
                        TopSelector(
                            options: UIDevice.isiPhone ? TopSelectorOption.allCases : [.all, .songs],
                            selected: $viewModel.currentViewMode,
                            allowScrolling: UIDevice.isiPhone
                        )
                    }

                    switch viewModel.currentViewMode {
                    case .all, .favorites, .songs:
                        VStack(spacing: .spacing(.xSmall)) {
                            VStack(spacing: .spacing(.xSmall)) {
                                if displayLongUpdateBanner {
                                    LongUpdateBanner(
                                        completedNumber: $viewModel.processedUpdateNumber,
                                        totalUpdateCount: $viewModel.totalUpdateCount
                                    )
                                    .padding(.horizontal, .spacing(.small))
                                }

//                                if shouldDisplayRecurringDonationBanner, viewModel.searchText.isEmpty {
//                                    RecurringDonationBanner(
//                                        isBeingShown: $shouldDisplayRecurringDonationBanner
//                                    )
//                                    .padding(.horizontal, 10)
//                                }
                            }

                            ContentGrid(
                                viewModel: allSoundsViewModel,
                                searchTextIsEmpty: $contentSearchTextIsEmpty,
                                allowSearch: true,
                                dataLoadingDidFail: viewModel.dataLoadingDidFail,
                                containerSize: geometry.size,
                                loadingView:
                                    VStack {
                                        HStack(spacing: .spacing(.small)) {
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
                                                .padding(.horizontal, .spacing(.xLarge))
                                        } else {
                                            Text("Nenhum som a ser exibido. Isso é esquisito.")
                                                .foregroundColor(.gray)
                                                .padding(.horizontal, .spacing(.large))
                                        }
                                    }
                                ,
                                errorView:
                                    VStack {
                                        HStack(spacing: .spacing(.small)) {
                                            ProgressView()

                                            Text("Erro ao carregar sons.")
                                                .foregroundColor(.gray)
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                            )

                            if viewModel.currentViewMode == .all, !UserSettings().getShowExplicitContent() {
                                ExplicitDisabledWarning(
                                    text: UIDevice.isiPhone ? Shared.contentFilterMessageForSoundsiPhone : Shared.contentFilterMessageForSoundsiPadMac
                                )
                                .padding(.top, explicitOffWarningTopPadding)
                                .padding(.horizontal, explicitOffWarningBottomPadding)
                            }

                            if viewModel.currentViewMode == .all, contentSearchTextIsEmpty ?? true {
                                Text("\(viewModel.forDisplay?.count ?? 0) ITENS")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, .spacing(.small))
                                    .padding(.bottom, Shared.Constants.soundCountPadBottomPadding)
                            }
                        }

                    case .folders:
                        MyFoldersiPhoneView()
                            .environmentObject(deleteFolderAide)
                        
                    case .authors:
                        AuthorsView(
                            sortOption: $viewModel.authorSortOption,
                            sortAction: $authorSortAction,
                            searchTextForControl: $authorSearchText,
                            containerWidth: geometry.size.width
                        )
                    }
                }
                .navigationTitle(Text(title))
                .navigationBarItems(
                    leading: LeadingToolbarControls(
                        isSelecting: currentContentListMode.wrappedValue == .selection,
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
                .onReceive(settingsHelper.$updateSoundsList) { shouldUpdate in // iPad - Settings explicit toggle.
                    if shouldUpdate {
                        viewModel.onExplicitContentSettingChanged()
                        settingsHelper.updateSoundsList = false
                    }
                }
                .onChange(of: trendsHelper.notifyMainSoundContainer) {
                    highlight(soundId: trendsHelper.notifyMainSoundContainer)
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
            .toast(viewModel.toast)
        }
    }
}

// MARK: - Subviews

extension MainContentView {

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
                if viewModel.currentViewMode == .authors {
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
                    if UIDevice.isiPhone && currentContentListMode.wrappedValue == .regular {
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
                                    currentContentListMode.wrappedValue == .selection ? "Cancelar Seleção" : "Selecionar",
                                    systemImage: currentContentListMode.wrappedValue == .selection ? "xmark.circle" : "checkmark.circle"
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

extension MainContentView {

    private func selectionNavBarTitle(for viewModel: ContentGridViewModel<[AnyEquatableMedoContent]>) -> String {
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
    MainContentView(
        viewModel: .init(
            currentViewMode: .all,
            soundSortOption: SoundSortOption.dateAddedDescending.rawValue,
            authorSortOption: AuthorSortOption.nameAscending.rawValue,
            currentContentListMode: .constant(.regular),
            toast: .constant(nil),
            syncValues: SyncValues()
        ),
        currentContentListMode: .constant(.regular),
        toast: .constant(nil),
        openSettingsAction: {}
    )
}
