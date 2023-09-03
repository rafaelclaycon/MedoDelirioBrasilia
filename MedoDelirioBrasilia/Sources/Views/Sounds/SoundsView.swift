//
//  SoundsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 19/05/22.
//

import SwiftUI

struct SoundsView: View {

    enum ViewMode: Int {
        case allSounds, favorites, folders, byAuthor
    }

    enum SubviewToOpen {
        case onboardingView, addToFolderView, shareAsVideoView, settingsView, whatsNewView, syncInfoView
    }

    @StateObject var viewModel: SoundsViewViewModel
    @State var currentViewMode: ViewMode
    @Binding var currentSoundsListMode: SoundsListMode
    @Binding var updateList: Bool
    @State private var searchText: String = .empty
    
    @State private var listWidth: CGFloat = 700
    @State private var columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    @Environment(\.sizeCategory) var sizeCategory
    
    @State private var subviewToOpen: SubviewToOpen = .onboardingView
    @State private var showingModalView = false
    
    // Temporary banners
    @State private var shouldDisplayRecurringDonationBanner: Bool = false
    @State private var shouldDisplayBetaBanner: Bool = false
    
    // Settings
    @EnvironmentObject var settingsHelper: SettingsHelper
    
    // Add to Folder vars
    @State private var hadSuccessAddingToFolder: Bool = false
    @State private var folderName: String? = nil
    @State private var pluralization: WordPluralization = .singular
    @State private var shouldDisplayAddedToFolderToast: Bool = false
    
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
    
    // Folders
    @StateObject var deleteFolderAide = DeleteFolderViewAideiPhone()
    
    // Toast views
    private let toastViewBottomPaddingPhone: CGFloat = 60
    private let toastViewBottomPaddingPad: CGFloat = 15

    // Dynamic Type
    @ScaledMetric private var explicitOffWarningTopPadding = 16
    @ScaledMetric private var explicitOffWarningPhoneBottomPadding = 20
    @ScaledMetric private var explicitOffWarningPadBottomPadding = 20
    @ScaledMetric private var soundCountTopPadding = 10
    @ScaledMetric private var soundCountPhoneBottomPadding = 68
    @ScaledMetric private var soundCountPadBottomPadding = 22

    // Networking
    @EnvironmentObject var networkMonitor: NetworkMonitor

    // Sync
    @AppStorage("lastUpdateAttempt") private var lastUpdateAttempt = ""
    @AppStorage("lastUpdateDate") private var lastUpdateDate = "all"

    private var searchResults: [Sound] {
        if searchText.isEmpty {
            return viewModel.sounds
        } else {
            return viewModel.sounds.filter { sound in
                let searchString = "\(sound.description.lowercased().withoutDiacritics()) \(sound.authorName?.lowercased().withoutDiacritics() ?? "")"
                return searchString.contains(searchText.lowercased().withoutDiacritics())
            }
        }
    }
    
    private var showNoFavoritesView: Bool {
        searchResults.isEmpty && currentViewMode == .favorites && searchText.isEmpty
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
        switch currentViewMode {
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
        if currentViewMode == .byAuthor {
            return authorSearchText.isEmpty
        } else {
            return searchText.isEmpty
        }
    }

    private var isLoadingSounds: Bool {
        searchResults.isEmpty && viewModel.sounds.isEmpty
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
                } else if currentViewMode == .folders {
                    MyFoldersiPhoneView()
                        .environmentObject(deleteFolderAide)
                } else if currentViewMode == .byAuthor {
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
                                    if !networkMonitor.isConnected {
                                        YoureOfflineView()
                                            //.padding(.horizontal, 10)
                                    }

//                                    if shouldDisplayRecurringDonationBanner, searchText.isEmpty {
//                                        RecurringDonationBanner(isBeingShown: $shouldDisplayRecurringDonationBanner)
//                                            .padding(.horizontal, 10)
//                                    }

                                    LazyVGrid(columns: columns, spacing: UIDevice.current.userInterfaceIdiom == .phone ? 14 : 20) {
                                        if searchResults.isEmpty {
                                            NoSearchResultsView(searchText: $searchText)
                                                .padding(.vertical, UIScreen.main.bounds.height / 4)
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
                                                    //dump(sound)
                                                    if currentSoundsListMode == .regular {
                                                        if viewModel.nowPlayingKeeper.contains(sound.id) {
                                                            AudioPlayer.shared?.togglePlay()
                                                            viewModel.nowPlayingKeeper.removeAll()
                                                        } else {
                                                            viewModel.play(sound: sound)
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
                                                                    if currentViewMode == .favorites {
                                                                        viewModel.reloadList(currentMode: currentViewMode)
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
                                                                viewModel.showEmailAppPicker_suggestOtherAuthorNameConfirmationDialog = true
                                                            } label: {
                                                                Label(SoundOptionsHelper.getSuggestOtherAuthorNameButtonTitle(authorId: sound.authorId), systemImage: "exclamationmark.bubble")
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .searchable(text: $searchText)
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
                                    .onReceive(trendsHelper.$soundIdToGoTo) { soundIdToGoTo in
                                        if shouldScrollToAndHighlight(soundId: soundIdToGoTo) {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
                                                withAnimation {
                                                    proxy.scrollTo(soundIdToGoTo, anchor: .center)
                                                }
                                                TapticFeedback.warning()
                                            }
                                        }
                                    }
                                }

                                if UserSettings.getShowExplicitContent() == false, currentViewMode != .favorites {
                                    Text(UIDevice.current.userInterfaceIdiom == .phone ? Shared.contentFilterMessageForSoundsiPhone : Shared.contentFilterMessageForSoundsiPadMac)
                                        .multilineTextAlignment(.center)
                                        .padding(.top, explicitOffWarningTopPadding)
                                        .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? explicitOffWarningPhoneBottomPadding : explicitOffWarningPadBottomPadding)
                                }

                                if searchText.isEmpty, currentViewMode != .favorites {
                                    Text("\(viewModel.sounds.count) SONS.")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                        .padding(.top, soundCountTopPadding)
                                        .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? soundCountPhoneBottomPadding : soundCountPadBottomPadding)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(Text(title))
            .navigationBarItems(leading: leadingToolbarControls(), trailing: trailingToolbarControls())
            .onAppear {
                viewModel.reloadList(currentMode: currentViewMode)

                columns = GridHelper.soundColumns(listWidth: listWidth, sizeCategory: sizeCategory)
                viewModel.donateActivity()
                viewModel.sendUserPersonalTrendsToServerIfEnabled()
                
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

                // if !AppPersistentMemory.getHasSeenRecurringDonationBanner() {
                //     networkRabbit.displayRecurringDonationBanner {
                //         shouldDisplayRecurringDonationBanner = $0
                //     }
                // }

                // shouldDisplayBetaBanner = !AppPersistentMemory.getHasSeenBetaBanner()
                
                if moveDatabaseIssue.isEmpty == false {
                    viewModel.showMoveDatabaseIssueAlert()
                }

                //print("MARSHA: \(lastUpdateDate)")
            }
            .sheet(isPresented: $viewModel.showEmailAppPicker_suggestOtherAuthorNameConfirmationDialog) {
                EmailAppPickerView(isBeingShown: $viewModel.showEmailAppPicker_suggestOtherAuthorNameConfirmationDialog,
                                   didCopySupportAddress: .constant(false),
                                   subject: String(format: Shared.suggestOtherAuthorNameEmailSubject, viewModel.selectedSound?.title ?? ""),
                                   emailBody: String(format: Shared.suggestOtherAuthorNameEmailBody, viewModel.selectedSound?.authorName ?? "", viewModel.selectedSound?.id ?? ""))
            }
            .sheet(isPresented: $viewModel.showEmailAppPicker_soundUnavailableConfirmationDialog) {
                EmailAppPickerView(isBeingShown: $viewModel.showEmailAppPicker_soundUnavailableConfirmationDialog,
                                   didCopySupportAddress: .constant(false),
                                   subject: Shared.issueSuggestionEmailSubject,
                                   emailBody: Shared.issueSuggestionEmailBody)
            }
            .sheet(isPresented: $viewModel.showEmailAppPicker_sendFeedback) {
                EmailAppPickerView(isBeingShown: $viewModel.showEmailAppPicker_sendFeedback,
                                   didCopySupportAddress: .constant(false),
                                   subject: "Feedback sobre o Medo e Delírio 7.0 Beta",
                                   emailBody: "Olá! Desejo receber o questionário para te ajudar com o projeto. Além disso, aqui está um feedback sobre o Beta:")
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
                }
            }
            .sheet(isPresented: $viewModel.isShowingShareSheet) {
                viewModel.iPadShareSheet
            }
            .sheet(isPresented: $showingModalView, onDismiss: {
                if subviewToOpen == .whatsNewView {
                    AppPersistentMemory.setHasSeen70WhatsNewScreen(to: true)
                }
            }) {
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
                        ShareAsVideoView(viewModel: ShareAsVideoViewViewModel(contentId: viewModel.selectedSound?.id ?? .empty, contentTitle: viewModel.selectedSound?.title ?? .empty, contentAuthor: viewModel.selectedSound?.authorName ?? .empty, audioFilename: viewModel.selectedSound?.filename ?? .empty), isBeingShown: $showingModalView, result: $shareAsVideo_Result, useLongerGeneratingVideoMessage: false)
                    } else {
                        ShareAsVideoLegacyView(viewModel: ShareAsVideoLegacyViewViewModel(contentId: viewModel.selectedSound?.id ?? .empty, contentTitle: viewModel.selectedSound?.title ?? .empty, audioFilename: viewModel.selectedSound?.filename ?? .empty), isBeingShown: $showingModalView, result: $shareAsVideo_Result, useLongerGeneratingVideoMessage: false)
                    }
                    
                case .settingsView:
                    SettingsCasingWithCloseView(isBeingShown: $showingModalView)
                        .environmentObject(settingsHelper)
                    
                case .whatsNewView:
                    WhatsNewView(isBeingShown: $showingModalView)

                case .syncInfoView:
                    SyncInfoView(
                        isBeingShown: $showingModalView,
                        lastUpdateAttempt: lastUpdateAttempt,
                        lastUpdateDate: lastUpdateDate
                    )
                }
            }
            .onReceive(settingsHelper.$updateSoundsList) { shouldUpdate in
                if shouldUpdate {
                    viewModel.reloadList(currentMode: currentViewMode)
                    settingsHelper.updateSoundsList = false
                }
            }
            .onChange(of: shareAsVideo_Result.videoFilepath) { videoResultPath in
                if videoResultPath.isEmpty == false {
                    if shareAsVideo_Result.exportMethod == .saveAsVideo {
                        viewModel.showVideoSavedSuccessfullyToast()
                    } else {
                        viewModel.shareVideo(withPath: videoResultPath, andContentId: shareAsVideo_Result.contentId)
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
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
                        withAnimation {
                            shouldDisplayAddedToFolderToast = true
                        }
                        TapticFeedback.success()
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            shouldDisplayAddedToFolderToast = false
                            folderName = nil
                            hadSuccessAddingToFolder = false
                        }
                    }
                    
                    if pluralization == .plural {
                        viewModel.sendUsageMetricToServer(action: "didAddManySoundsToFolder(\(selectedCount))")
                    }
                }
            }
            .onChange(of: updateList) { updateList in
                if updateList {
                    viewModel.reloadList(currentMode: currentViewMode)
                }
            }
            
            if displayFloatingSelectorView {
                VStack {
                    Spacer()

                    floatingSelectorView()
                        .padding()
                }
            }
            
            if shouldDisplayAddedToFolderToast {
                VStack {
                    Spacer()
                    
                    ToastView(text: pluralization.getAddedToFolderToastText(folderName: folderName))
                        .padding(.horizontal)
                        .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? toastViewBottomPaddingPhone : toastViewBottomPaddingPad)
                }
                .transition(.moveAndFade)
            }
            
            if viewModel.displaySharedSuccessfullyToast {
                VStack {
                    Spacer()
                    
                    ToastView(text: viewModel.shareBannerMessage)
                        .padding(.horizontal)
                        .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? toastViewBottomPaddingPhone : toastViewBottomPaddingPad)
                }
                .transition(.moveAndFade)
            }
        }
    }
    
    @ViewBuilder func floatingSelectorView() -> some View {
        Picker("Exibição", selection: $currentViewMode) {
            Text("Todos")
                .tag(ViewMode.allSounds)
            
            Text("Favoritos")
                .tag(ViewMode.favorites)
            
            Text("Pastas")
                .tag(ViewMode.folders)
            
            Text("Por Autor")
                .tag(ViewMode.byAuthor)
        }
        .pickerStyle(.segmented)
        .background(.regularMaterial)
        .cornerRadius(8)
        .onChange(of: currentViewMode) { viewModel.reloadList(currentMode: $0) }
        .disabled(isLoadingSounds && currentViewMode == .allSounds)
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
            
//            Button {
//                viewModel.shareSelected()
//            } label: {
//                Label("Compartilhar", systemImage: "square.and.arrow.up")
//            }.disabled(viewModel.selectionKeeper.count == 0 || viewModel.selectionKeeper.count > 5)
        } else {
            if UIDevice.current.userInterfaceIdiom == .phone {
                HStack {
                    Button {
                        subviewToOpen = .settingsView
                        showingModalView = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    
                    BetaTagView()
                }
            } else {
                BetaTagView()
            }
        }
    }
    
    @ViewBuilder func trailingToolbarControls() -> some View {
        if currentViewMode == .folders {
            EmptyView()
        } else {
            HStack(spacing: 15) {
                if currentViewMode == .byAuthor {
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
                    if currentSoundsListMode == .selection {
                        Button {
                            // Need to get count before clearing the Set.
                            let selectedCount: Int = viewModel.selectionKeeper.count
                            
                            if currentViewMode == .favorites || viewModel.allSelectedAreFavorites() {
                                viewModel.removeSelectedFromFavorites()
                                viewModel.stopSelecting()
                                viewModel.reloadList(currentMode: currentViewMode)
                                viewModel.sendUsageMetricToServer(action: "didRemoveManySoundsFromFavorites(\(selectedCount))")
                            } else {
                                viewModel.addSelectedToFavorites()
                                viewModel.stopSelecting()
                                viewModel.sendUsageMetricToServer(action: "didAddManySoundsToFavorites(\(selectedCount))")
                            }
                        } label: {
                            Image(systemName: currentViewMode == .favorites || viewModel.allSelectedAreFavorites() ? "star.slash" : "star")
                        }.disabled(viewModel.selectionKeeper.count == 0)
                        
                        Button {
                            viewModel.prepareSelectedToAddToFolder()
                            subviewToOpen = .addToFolderView
                            showingModalView = true
                        } label: {
                            Image(systemName: "folder.badge.plus")
                        }.disabled(viewModel.selectionKeeper.count == 0)
                    } else {
                        Button("Dar Feedback") {
                            viewModel.showEmailAppPicker_sendFeedback = true
                        }

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
                            }.disabled(currentViewMode == .favorites && viewModel.sounds.count == 0)
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
        guard soundId.isEmpty == false else {
            return false
        }
        currentViewMode = .allSounds
        
        if searchText.isEmpty == false {
            searchText = .empty
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        
        viewModel.highlightKeeper.insert(soundId)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            viewModel.highlightKeeper.remove(soundId)
        }
        
        self.trendsHelper.soundIdToGoTo = .empty
        return true // This tells the ScrollViewProxy "yes, go ahead and scroll, there was a soundId received". Unfortunately, passing the proxy as a parameter did not work and this code was made more complex because of this.
    }
}

struct SoundsView_Previews: PreviewProvider {

    static var previews: some View {
        SoundsView(viewModel: SoundsViewViewModel(soundSortOption: SoundSortOption.dateAddedDescending.rawValue,
                                                  authorSortOption: AuthorSortOption.nameAscending.rawValue,
                                                  currentSoundsListMode: .constant(.regular)),
                   currentViewMode: .allSounds,
                   currentSoundsListMode: .constant(.regular),
                   updateList: .constant(true))
    }

}
