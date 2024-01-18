//
//  SoundsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 19/05/22.
//

import SwiftUI

struct SoundsView: View {

    enum SubviewToOpen {
        case onboardingView, addToFolderView, shareAsVideoView, settingsView, whatsNewView, syncInfoView, soundDetailView, retrospective
    }

    @StateObject var viewModel: SoundsViewViewModel
    @Binding var currentSoundsListMode: SoundsListMode
    
    @State private var listWidth: CGFloat = 700
    @State private var columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    @Environment(\.sizeCategory) var sizeCategory
    
    @State private var subviewToOpen: SubviewToOpen = .onboardingView
    @State private var showingModalView = false
    
    // Temporary banners
    @State private var shouldDisplayRecurringDonationBanner: Bool = false
    @State private var shouldDisplayRetrospectiveBanner: Bool = false
    @State private var shouldDisplayUpdateIncentiveBanner: Bool = false

    // Settings
    @EnvironmentObject var settingsHelper: SettingsHelper
    
    // Add to Folder vars
    @State private var hadSuccessAddingToFolder: Bool = false
    @State private var folderName: String? = nil
    @State private var pluralization: WordPluralization = .singular
    
    // Share as Video
    @State private var shareAsVideo_Result = ShareAsVideoResult()
    
    // View All Sounds By This Author
    @State var authorToAutoOpen: Author = Author(id: .empty, name: .empty)
    @State var autoOpenAuthor: Bool = false
    
    // Sort Authors
    @State var authorSortAction: AuthorSortOption = .nameAscending
    @State var authorSearchText: String = .empty
    
    // Trends
    @EnvironmentObject var trendsHelper: TrendsHelper
    @State private var soundIdToGoTo: String = ""

    // Folders
    @StateObject var deleteFolderAide = DeleteFolderViewAideiPhone()
    
    // Toast views
    private let toastViewBottomPaddingPhone: CGFloat = 60
    private let toastViewBottomPaddingPad: CGFloat = 15

    // Dynamic Type
    @ScaledMetric private var explicitOffWarningTopPadding = 16
    @ScaledMetric private var explicitOffWarningBottomPadding = 20
    @ScaledMetric private var soundCountTopPadding = 10
    @ScaledMetric private var soundCountPhoneBottomPadding = 68
    @ScaledMetric private var soundCountPadBottomPadding = 22

    // Networking
    @EnvironmentObject var networkMonitor: NetworkMonitor

    // Sync
    @State private var shouldDisplayYoureOfflineBanner: Bool = true

    // Select Many
    @State private var areManyActionButtonsEnabled = false
    @State private var favoriteButtonTitle = "Favoritar"
    @State private var favoriteButtonImage = "star"

    // Retro 2023
    @State private var retroExportAnalytics: String = ""

    private var searchResults: [Sound] {
        if viewModel.searchText.isEmpty {
            return viewModel.sounds
        } else {
            return viewModel.sounds.filter { sound in
                let searchString = "\(sound.description.lowercased().withoutDiacritics()) \(sound.authorName?.lowercased().withoutDiacritics() ?? "")"
                return searchString.contains(viewModel.searchText.lowercased().withoutDiacritics())
            }
        }
    }
    
    private var showNoFavoritesView: Bool {
        searchResults.isEmpty && viewModel.currentViewMode == .favorites && viewModel.searchText.isEmpty
    }
    
    private var title: String {
        guard currentSoundsListMode == .regular else {
            if viewModel.selectionKeeper.count == 0 {
                return Shared.SoundSelection.selectSounds
            } else if viewModel.selectionKeeper.count == 1 {
                return Shared.SoundSelection.soundSelectedSingular
            } else {
                return String(format: Shared.SoundSelection.soundsSelectedPlural, viewModel.selectionKeeper.count)
            }
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
        guard currentSoundsListMode == .regular else { return false }
        if viewModel.currentViewMode == .byAuthor {
            return authorSearchText.isEmpty
        } else {
            return viewModel.searchText.isEmpty
        }
    }

    private var isLoadingSounds: Bool {
        searchResults.isEmpty && viewModel.sounds.isEmpty
    }

    private var isAllowedToRefresh: Bool {
        viewModel.currentViewMode == .allSounds && currentSoundsListMode == .regular
    }

    var body: some View {
        ZStack {
            VStack {
                NavigationLink(destination: AuthorDetailView(viewModel: AuthorDetailViewViewModel(originatingScreenName: Shared.ScreenNames.soundsView,
                                                                                                  authorName: authorToAutoOpen.name, currentSoundsListMode: $currentSoundsListMode),
                                                             author: authorToAutoOpen,
                                                             currentSoundsListMode: $currentSoundsListMode),
                               isActive: $autoOpenAuthor) { EmptyView() }

                if showNoFavoritesView {
                    NoFavoritesView()
                        .padding(.horizontal, 25)
                        .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? 100 : 15)
                } else if viewModel.currentViewMode == .folders {
                    MyFoldersiPhoneView()
                        .environmentObject(deleteFolderAide)
                } else if viewModel.currentViewMode == .byAuthor {
                    AuthorsView(sortOption: $viewModel.authorSortOption, sortAction: $authorSortAction, searchTextForControl: $authorSearchText)
                } else {
                    GeometryReader { geometry in
                        if isLoadingSounds {
                            VStack {
                                HStack(spacing: 10) {
                                    ProgressView()

                                    Text("Carregando sons...")
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .frame(width: geometry.size.width)
                            .frame(minHeight: geometry.size.height)
                        } else {
                            ScrollView {
                                ScrollViewReader { proxy in
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

                                    if shouldDisplayRecurringDonationBanner, viewModel.searchText.isEmpty {
                                        RecurringDonationBanner(isBeingShown: $shouldDisplayRecurringDonationBanner)
                                            .padding(.horizontal, 10)
                                    }

                                    if shouldDisplayRetrospectiveBanner, viewModel.searchText.isEmpty {
                                        RetroBanner(
                                            isBeingShown: $shouldDisplayRetrospectiveBanner,
                                            buttonAction: {
                                                subviewToOpen = .retrospective
                                                showingModalView = true
                                            }
                                        )
                                        .padding(.horizontal, 10)
                                    }

                                    if shouldDisplayUpdateIncentiveBanner, viewModel.searchText.isEmpty {
                                        UpdateIncentiveBanner(
                                            isBeingShown: $shouldDisplayUpdateIncentiveBanner
                                        )
                                        .padding(.horizontal, 10)
                                    }

                                    LazyVGrid(columns: columns, spacing: UIDevice.current.userInterfaceIdiom == .phone ? 14 : 20) {
                                        if searchResults.isEmpty {
                                            NoSearchResultsView(searchText: $viewModel.searchText)
                                        } else {
                                            ForEach(searchResults) { sound in
                                                SoundCell(sound: sound,
                                                          favorites: $viewModel.favoritesKeeper,
                                                          highlighted: $viewModel.highlightKeeper,
                                                          nowPlaying: $viewModel.nowPlayingKeeper,
                                                          selectedItems: $viewModel.selectionKeeper,
                                                          currentSoundsListMode: $currentSoundsListMode)
                                                .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 20, style: .continuous))
                                                .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 0 : 5)
                                                .onTapGesture {
                                                    if currentSoundsListMode == .regular {
                                                        if viewModel.nowPlayingKeeper.contains(sound.id) {
                                                            AudioPlayer.shared?.togglePlay()
                                                            viewModel.nowPlayingKeeper.removeAll()
                                                        } else {
                                                            viewModel.play(sound)
                                                        }
                                                    } else {
                                                        if viewModel.selectionKeeper.contains(sound.id) {
                                                            viewModel.selectionKeeper.remove(sound.id)
                                                        } else {
                                                            viewModel.selectionKeeper.insert(sound.id)
                                                        }
                                                    }
                                                }
                                                .contextMenu {
                                                    if currentSoundsListMode != .selection {
                                                        Section {
                                                            Button {
                                                                viewModel.share(sound: sound)
                                                            } label: {
                                                                Label(Shared.shareSoundButtonText, systemImage: "square.and.arrow.up")
                                                            }

                                                            Button {
                                                                viewModel.selectedSound = sound
                                                                subviewToOpen = .shareAsVideoView
                                                                showingModalView = true
                                                            } label: {
                                                                Label(Shared.shareAsVideoButtonText, systemImage: "film")
                                                            }
                                                        }

                                                        Section {
                                                            Button {
                                                                if viewModel.favoritesKeeper.contains(sound.id) {
                                                                    viewModel.removeFromFavorites(soundId: sound.id)
                                                                    if viewModel.currentViewMode == .favorites {
                                                                        viewModel.reloadList(currentMode: viewModel.currentViewMode)
                                                                    }
                                                                } else {
                                                                    viewModel.addToFavorites(soundId: sound.id)
                                                                }
                                                            } label: {
                                                                Label(viewModel.favoritesKeeper.contains(sound.id) ? Shared.removeFromFavorites : Shared.addToFavorites, systemImage: viewModel.favoritesKeeper.contains(sound.id) ? "star.slash" : "star")
                                                            }

                                                            Button {
                                                                viewModel.selectedSounds = [Sound]()
                                                                viewModel.selectedSounds?.append(sound)
                                                                subviewToOpen = .addToFolderView
                                                                showingModalView = true
                                                            } label: {
                                                                Label(Shared.addToFolderButtonText, systemImage: "folder.badge.plus")
                                                            }
                                                        }

                                                        Section {
                                                            Button {
                                                                guard let author = try? LocalDatabase.shared.author(withId: sound.authorId) else { return }
                                                                authorToAutoOpen = author
                                                                autoOpenAuthor = true
                                                            } label: {
                                                                Label("Ver Todos os Sons Desse Autor", systemImage: "person")
                                                            }

                                                            Button {
                                                                viewModel.selectedSound = sound
                                                                subviewToOpen = .soundDetailView
                                                                showingModalView = true
                                                            } label: {
                                                                Label("Ver Detalhes", systemImage: "info.circle")
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .searchable(text: $viewModel.searchText)
                                    .disableAutocorrection(true)
                                    .padding(.horizontal)
                                    .padding(.top, 7)
                                    .onChange(of: geometry.size.width) { newWidth in
                                        self.listWidth = newWidth
                                        columns = GridHelper.soundColumns(listWidth: listWidth, sizeCategory: sizeCategory)
                                    }
                                    .onChange(of: searchResults) { searchResults in
                                        if searchResults.isEmpty {
                                            columns = [GridItem(.flexible())]
                                        } else {
                                            columns = GridHelper.soundColumns(listWidth: listWidth, sizeCategory: sizeCategory)
                                        }
                                    }
                                    .onChange(of: soundIdToGoTo) {
                                        if !$0.isEmpty {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
                                                withAnimation {
                                                    proxy.scrollTo(soundIdToGoTo, anchor: .center)
                                                }
                                                TapticFeedback.warning()
                                            }
                                        }
                                    }
                                }

                                if UserSettings.getShowExplicitContent() == false, viewModel.currentViewMode != .favorites {
                                    ExplicitDisabledWarning(
                                        text: UIDevice.isiPhone ? Shared.contentFilterMessageForSoundsiPhone : Shared.contentFilterMessageForSoundsiPadMac
                                    )
                                    .padding(.top, explicitOffWarningTopPadding)
                                    .padding(.horizontal, explicitOffWarningBottomPadding)
                                }

                                if viewModel.searchText.isEmpty, viewModel.currentViewMode != .favorites {
                                    Text("\(viewModel.sounds.count) SONS")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                        .padding(.top, soundCountTopPadding)
                                        .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? soundCountPhoneBottomPadding : soundCountPadBottomPadding)
                                }
                            }
                            .if(isAllowedToRefresh) {
                                $0.refreshable {
                                    Task { // Keep this Task to avoid "cancelled" issue.
                                        await viewModel.sync(lastAttempt: AppPersistentMemory.getLastUpdateAttempt())
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(Text(title))
            .navigationBarItems(leading: leadingToolbarControls(), trailing: trailingToolbarControls())
            .onAppear {
                print("SOUNDS VIEW - ON APPEAR")
                viewModel.reloadList(currentMode: viewModel.currentViewMode)

                columns = GridHelper.soundColumns(listWidth: listWidth, sizeCategory: sizeCategory)
                viewModel.donateActivity()
                Task {
                    await viewModel.sendUserPersonalTrendsToServerIfEnabled()
                }

                if AppPersistentMemory.getHasShownNotificationsOnboarding() == false {
                    subviewToOpen = .onboardingView
                    showingModalView = true
                    AppPersistentMemory.setHasSeen70WhatsNewScreen(to: true) // Prevent the What's New screen from appearing when switching tabs
                } else if AppPersistentMemory.getHasSeen70WhatsNewScreen() == false {
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        subviewToOpen = .whatsNewView
                        showingModalView = true
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            subviewToOpen = .whatsNewView
                            showingModalView = true
                        }
                    }
                }

                if !AppPersistentMemory.getHasSeenRecurringDonationBanner() {
                    Task {
                        NetworkRabbit.shared.displayRecurringDonationBanner {
                            shouldDisplayRecurringDonationBanner = $0
                        }
                    }
                }

                Task {
                    if AppPersistentMemory.getHasSeenRetroBanner() {
                        shouldDisplayRetrospectiveBanner = false
                    } else {
                        shouldDisplayRetrospectiveBanner = await RetroView.ViewModel.shouldDisplayBanner()
                    }
                }

                if !AppPersistentMemory.getHasSeenFirstUpdateIncentiveBanner() {
                    shouldDisplayUpdateIncentiveBanner = UpdateIncentive.shouldDisplayBanner(
                        currentSystemVersion: UIDevice.current.systemVersion,
                        deviceModel: UIDevice.modelName
                    )
                }

                // TODO: Needs refactor. .onAppear is called before the AppDelegate, rendering this useless.
                if moveDatabaseIssue.isEmpty == false {
                    viewModel.showMoveDatabaseIssueAlert()
                }
            }
            .sheet(isPresented: $viewModel.showEmailAppPicker_soundUnavailableConfirmationDialog) {
                EmailAppPickerView(isBeingShown: $viewModel.showEmailAppPicker_soundUnavailableConfirmationDialog,
                                   didCopySupportAddress: .constant(false),
                                   subject: Shared.issueSuggestionEmailSubject,
                                   emailBody: Shared.issueSuggestionEmailBody)
            }
            .alert(isPresented: $viewModel.showAlert) {
                switch viewModel.alertType {
                case .singleOption:
                    return Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))

                case .twoOptions:
                    return Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage), primaryButton: .default(Text("Relatar Problema por E-mail"), action: {
                        viewModel.showEmailAppPicker_soundUnavailableConfirmationDialog = true
                    }), secondaryButton: .cancel(Text("Fechar")))

                case .twoOptionsOneDelete:
                    return Alert(title: Text(deleteFolderAide.alertTitle), message: Text(deleteFolderAide.alertMessage), primaryButton: .destructive(Text("Apagar"), action: {
                        guard deleteFolderAide.folderIdForDeletion.isEmpty == false else {
                            return
                        }
                        try? LocalDatabase.shared.deleteUserFolder(withId: deleteFolderAide.folderIdForDeletion)
                        deleteFolderAide.updateFolderList = true
                        deleteFolderAide.showAlert = false
                    }), secondaryButton: .cancel(Text("Cancelar")))

                case .twoOptionsOneRedownload:
                    return Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage), primaryButton: .default(Text("Baixar Conteúdo Novamente"), action: {
                        guard let content = viewModel.selectedSound else { return }
                        viewModel.redownloadServerContent(withId: content.id)
                    }), secondaryButton: .cancel(Text("Fechar")))

                case .twoOptionsOneContinue:
                    return Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage), primaryButton: .default(Text("Continuar"), action: {
                        AppPersistentMemory.increaseShareManyMessageShowCountByOne()
                        viewModel.shareSelected()
                    }), secondaryButton: .cancel(Text("Cancelar")))
                }
            }
            .sheet(isPresented: $viewModel.isShowingShareSheet) {
                viewModel.iPadShareSheet
            }
            .sheet(isPresented: $showingModalView) {
                switch subviewToOpen {
                 case .onboardingView:
                    OnboardingView(isBeingShown: $showingModalView)
                        .interactiveDismissDisabled(UIDevice.current.userInterfaceIdiom == .phone ? true : false)
                    
                case .addToFolderView:
                    AddToFolderView(isBeingShown: $showingModalView,
                                    hadSuccess: $hadSuccessAddingToFolder,
                                    folderName: $folderName,
                                    pluralization: $pluralization,
                                    selectedSounds: viewModel.selectedSounds!)
                    
                case .shareAsVideoView:
                    if #available(iOS 16.0, *) {
                        ShareAsVideoView(
                            viewModel: ShareAsVideoViewViewModel(content: viewModel.selectedSound!, subtitle: viewModel.selectedSound?.authorName ?? .empty),
                            isBeingShown: $showingModalView,
                            result: $shareAsVideo_Result,
                            useLongerGeneratingVideoMessage: false
                        )
                    } else {
                        ShareAsVideoLegacyView(
                            viewModel: ShareAsVideoLegacyViewViewModel(content: viewModel.selectedSound!),
                            isBeingShown: $showingModalView,
                            result: $shareAsVideo_Result,
                            useLongerGeneratingVideoMessage: false
                        )
                    }
                    
                case .settingsView:
                    SettingsCasingWithCloseView(isBeingShown: $showingModalView)
                        .environmentObject(settingsHelper)
                    
                case .whatsNewView:
                    WhatsNewView(isBeingShown: $showingModalView)

                case .syncInfoView:
                    SyncInfoView(
                        isBeingShown: $showingModalView,
                        lastUpdateAttempt: AppPersistentMemory.getLastUpdateAttempt(),
                        lastUpdateDate: AppPersistentMemory.getLastUpdateDate()
                    )

                case .soundDetailView:
                    SoundDetailView(
                        isBeingShown: $showingModalView,
                        sound: viewModel.selectedSound ?? Sound(title: "")
                    )

                case .retrospective:
                    RetroView(
                        viewModel: .init(),
                        isBeingShown: $showingModalView,
                        analyticsString: $retroExportAnalytics
                    )
                }
            }
            .onReceive(settingsHelper.$updateSoundsList) { shouldUpdate in
                if shouldUpdate {
                    viewModel.reloadList(currentMode: viewModel.currentViewMode)
                    settingsHelper.updateSoundsList = false
                }
            }
            .onChange(of: shareAsVideo_Result.videoFilepath) { videoResultPath in
                if videoResultPath.isEmpty == false {
                    if shareAsVideo_Result.exportMethod == .saveAsVideo {
                        viewModel.showVideoSavedSuccessfullyToast()
                    } else {
                        viewModel.shareVideo(
                            withPath: videoResultPath,
                            andContentId: shareAsVideo_Result.contentId,
                            title: viewModel.selectedSound?.title ?? ""
                        )
                    }
                }
            }
            .onChange(of: deleteFolderAide.showAlert) { showAlert in
                if showAlert {
                    viewModel.alertType = .twoOptionsOneDelete
                    viewModel.showAlert = true
                }
            }
            .onChange(of: showingModalView) { showingModalView in
                if (showingModalView == false) && hadSuccessAddingToFolder {
                    // Need to get count before clearing the Set.
                    let selectedCount: Int = viewModel.selectionKeeper.count

                    if currentSoundsListMode == .selection {
                        viewModel.stopSelecting()
                    }

                    viewModel.displayToast(toastText: pluralization.getAddedToFolderToastText(folderName: folderName)) {
                        folderName = nil
                        hadSuccessAddingToFolder = false
                    }

                    if pluralization == .plural {
                        Analytics.sendUsageMetricToServer(
                            originatingScreen: "SoundsView",
                            action: "didAddManySoundsToFolder(\(selectedCount))"
                        )
                    }
                } else if 
                    (showingModalView == false) &&
                    subviewToOpen == .retrospective &&
                    !retroExportAnalytics.isEmpty
                {
                    viewModel.displayToast(
                        toastText: "Imagens salvas com sucesso."
                    )

                    Analytics.sendUsageMetricToServer(
                        originatingScreen: "SoundsView",
                        action: "didExportRetro2023Images(\(retroExportAnalytics))"
                    )

                    retroExportAnalytics = ""
                }
            }
            .onChange(of: viewModel.selectionKeeper.count) {
                guard currentSoundsListMode == .selection else { return }
                areManyActionButtonsEnabled = $0 > 0
                if viewModel.currentViewMode == .favorites || viewModel.allSelectedAreFavorites() {
                    favoriteButtonTitle = "Desfav."
                    favoriteButtonImage = "star.slash"
                } else {
                    favoriteButtonTitle = "Favoritar"
                    favoriteButtonImage = "star"
                }
            }
            .onReceive(trendsHelper.$soundIdToGoTo) {
                if shouldScrollToAndHighlight(soundId: $0) {
                    soundIdToGoTo = $0
                }
            }
            .oneTimeTask {
                print("SOUNDS VIEW - ONE TIME TASK")
                if viewModel.currentViewMode == .allSounds {
                    await viewModel.sync(lastAttempt: AppPersistentMemory.getLastUpdateAttempt())
                }
            }

            if displayFloatingSelectorView {
                VStack {
                    Spacer()

                    floatingSelectorView()
                        .padding()
                }
            }

            if currentSoundsListMode == .selection {
                VStack {
                    Spacer()

                    FloatingSelectionOptionsView(
                        areButtonsEnabled: $areManyActionButtonsEnabled,
                        favoriteTitle: $favoriteButtonTitle,
                        favoriteSystemImage: $favoriteButtonImage,
                        shareIsProcessing: $viewModel.shareManyIsProcessing,
                        favoriteAction: {
                            viewModel.addRemoveManyFromFavorites()
                        },
                        folderAction: {
                            viewModel.prepareSelectedToAddToFolder()
                            subviewToOpen = .addToFolderView
                            showingModalView = true
                        },
                        shareAction: {
                            viewModel.showShareManyAlert()
                        }
                    )
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
                    .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? toastViewBottomPaddingPhone : toastViewBottomPaddingPad)
                }
                .transition(.moveAndFade)
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
        .onChange(of: viewModel.currentViewMode) { viewModel.reloadList(currentMode: $0) }
        .disabled(isLoadingSounds && viewModel.currentViewMode == .allSounds)
    }
    
    @ViewBuilder func leadingToolbarControls() -> some View {
        if currentSoundsListMode == .selection {
            Button {
                currentSoundsListMode = .regular
                viewModel.selectionKeeper.removeAll()
            } label: {
                Text("Cancelar")
                    .bold()
            }
        } else {
            if UIDevice.current.userInterfaceIdiom == .phone {
                Button {
                    subviewToOpen = .settingsView
                    showingModalView = true
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
                    .onChange(of: viewModel.authorSortOption, perform: { authorSortOption in
                        authorSortAction = AuthorSortOption(rawValue: authorSortOption) ?? .nameAscending
                    })
                } else {
                    if currentSoundsListMode == .regular {
                        SyncStatusView()
                            .onTapGesture {
                                subviewToOpen = .syncInfoView
                                showingModalView = true
                            }
                    }

                    Menu {
                        Section {
                            Button {
                                viewModel.startSelecting()
                            } label: {
                                Label(currentSoundsListMode == .selection ? "Cancelar Seleção" : "Selecionar", systemImage: currentSoundsListMode == .selection ? "xmark.circle" : "checkmark.circle")
                            }.disabled(viewModel.currentViewMode == .favorites && viewModel.sounds.count == 0)
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
                    .onChange(of: viewModel.soundSortOption) {
                        viewModel.sortSounds(by: SoundSortOption(rawValue: $0) ?? .dateAddedDescending)
                        UserSettings.setSoundSortOption(to: $0)
                    }
                }
            }
        }
    }
    
    private func shouldScrollToAndHighlight(soundId: String) -> Bool {
        guard !soundId.isEmpty else { return false }
        viewModel.currentViewMode = .allSounds

        if !viewModel.searchText.isEmpty {
            viewModel.searchText = ""
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }

        viewModel.highlightKeeper.insert(soundId)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            viewModel.highlightKeeper.remove(soundId)
        }

        self.trendsHelper.soundIdToGoTo = ""
        return true // This tells the ScrollViewProxy "yes, go ahead and scroll, there was a soundId received". Unfortunately, passing the proxy as a parameter did not work and this code was made more complex because of this.
    }
}

struct SoundsView_Previews: PreviewProvider {
    static var previews: some View {
        SoundsView(
            viewModel: SoundsViewViewModel(
                currentViewMode: .allSounds,
                soundSortOption: SoundSortOption.dateAddedDescending.rawValue,
                authorSortOption: AuthorSortOption.nameAscending.rawValue,
                currentSoundsListMode: .constant(.regular),
                syncValues: SyncValues()
            ),
            currentSoundsListMode: .constant(.regular)
        )
    }
}
