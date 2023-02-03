//
//  SoundsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 19/05/22.
//

import SwiftUI

struct SoundsView: View {

    enum Mode: Int {
        case allSounds, favorites, folders, byAuthor
    }
    
    enum SubviewToOpen {
        case onboardingView, addToFolderView, shareAsVideoView, settingsView
    }
    
    @StateObject var viewModel: SoundsViewViewModel
    @State var currentMode: Mode
    @State private var searchText: String = .empty
    
    @State private var listWidth: CGFloat = 700
    @State private var columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    @Environment(\.sizeCategory) var sizeCategory
    
    @State private var subviewToOpen: SubviewToOpen = .onboardingView
    @State private var showingModalView = false
    
    // Temporary banners
    //@State private var shouldDisplayHotWheatherBanner: Bool = false
    
    // Settings
    @EnvironmentObject var settingsHelper: SettingsHelper
    
    // Add to Folder vars
    @State private var hadSuccessAddingToFolder: Bool = false
    @State private var folderName: String? = nil
    @State private var shouldDisplayAddedToFolderToast: Bool = false
    
    // Share as Video
    @State private var shareAsVideo_Result = ShareAsVideoResult()
    
    // View All Sounds By This Author
    @State var authorToAutoOpen: Author = Author(id: .empty, name: .empty)
    @State var autoOpenAuthor: Bool = false
    
    // Sort Authors
    @State var authorSortAction: AuthorSortOption = .nameAscending
    
    // Trends
    @EnvironmentObject var trendsHelper: TrendsHelper
    
    // Folders
    @StateObject var deleteFolderAide = DeleteFolderViewAideiPhone()
    
    // Toast views
    private let toastViewBottomPaddingPhone: CGFloat = 60
    private let toastViewBottomPaddingPad: CGFloat = 15
    
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
        searchResults.isEmpty && currentMode == .favorites && searchText.isEmpty
    }
    
    private var title: String {
        switch currentMode {
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
    
    var body: some View {
        ZStack {
            VStack {
                NavigationLink(destination: AuthorDetailView(viewModel: AuthorDetailViewViewModel(originatingScreenName: Shared.ScreenNames.soundsView,
                                                                                                  authorName: authorToAutoOpen.name),
                                                             author: authorToAutoOpen),
                               isActive: $autoOpenAuthor) { EmptyView() }
                
                if showNoFavoritesView {
                    NoFavoritesView()
                        .padding(.horizontal, 25)
                        .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? 100 : 15)
                } else if currentMode == .folders {
                    MyFoldersiPhoneView()
                        .environmentObject(deleteFolderAide)
                } else if currentMode == .byAuthor {
                    AuthorsView(sortOption: $viewModel.authorSortOption, sortAction: $authorSortAction)
                } else {
                    GeometryReader { geometry in
                        ScrollView {
                            ScrollViewReader { proxy in
                                LazyVGrid(columns: columns, spacing: UIDevice.current.userInterfaceIdiom == .phone ? 14 : 20) {
                                    if searchResults.isEmpty {
                                        VStack {
                                            Spacer()
                                            
                                            Text("Nenhum Resultado")
                                                .foregroundColor(.gray)
                                                .font(.title3)
                                                .multilineTextAlignment(.center)
                                            
                                            Spacer()
                                        }
                                        .padding(.vertical, UIScreen.main.bounds.height / 3)
                                    } else {
                                        ForEach(searchResults) { sound in
                                            SoundCell(soundId: sound.id, title: sound.title, author: sound.authorName ?? "", isNew: sound.isNew ?? false, favorites: $viewModel.favoritesKeeper, highlighted: $viewModel.highlightKeeper, nowPlaying: $viewModel.nowPlayingKeeper)
                                                .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 20, style: .continuous))
                                                .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 0 : 5)
                                                .onTapGesture {
                                                    if viewModel.nowPlayingKeeper.contains(sound.id) {
                                                        player?.togglePlay()
                                                        viewModel.nowPlayingKeeper.removeAll()
                                                    } else {
                                                        viewModel.playSound(fromPath: sound.filename, withId: sound.id)
                                                    }
                                                }
                                                .contextMenu(menuItems: {
                                                    Section {
                                                        Button {
                                                            viewModel.shareSound(withPath: sound.filename, andContentId: sound.id)
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
                                                                if currentMode == .favorites {
                                                                    viewModel.reloadList(withSounds: soundData,
                                                                                         andFavorites: try? database.getAllFavorites(),
                                                                                         allowSensitiveContent: UserSettings.getShowOffensiveSounds(),
                                                                                         favoritesOnly: currentMode == .favorites,
                                                                                         sortedBy: SoundSortOption(rawValue: UserSettings.getSoundSortOption()) ?? .titleAscending)
                                                                }
                                                            } else {
                                                                viewModel.addToFavorites(soundId: sound.id)
                                                            }
                                                        } label: {
                                                            Label(viewModel.favoritesKeeper.contains(sound.id) ? "Remover dos Favoritos" : "Adicionar aos Favoritos", systemImage: viewModel.favoritesKeeper.contains(sound.id) ? "star.slash" : "star")
                                                        }
                                                        
                                                        Button {
                                                            viewModel.selectedSound = sound
                                                            subviewToOpen = .addToFolderView
                                                            showingModalView = true
                                                        } label: {
                                                            Label(Shared.addToFolderButtonText, systemImage: "folder.badge.plus")
                                                        }
                                                        .onChange(of: showingModalView) { showingModalView in
                                                            if (showingModalView == false) && hadSuccessAddingToFolder {
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
                                                            }
                                                        }
                                                    }
                                                    
                                                    Section {
                                                        Button {
                                                            guard let author = authorData.first(where: { $0.id == sound.authorId }) else {
                                                                return
                                                            }
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
                                                })
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
                            
                            if UserSettings.getShowOffensiveSounds() == false, currentMode != .favorites {
                                Text(UIDevice.current.userInterfaceIdiom == .phone ? Shared.contentFilterMessageForSoundsiPhone : Shared.contentFilterMessageForSoundsiPadMac)
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 15)
                                    .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 20 : 40)
                            }
                            
                            if searchText.isEmpty, currentMode != .favorites {
                                Text("\(viewModel.sounds.count) sons. Atualizado em \(soundsLastUpdateDate).")
                                    .font(.subheadline)
                                    .bold()
                                    .padding(.top, 10)
                                    .padding(.bottom, UIDevice.current.userInterfaceIdiom == .phone ? 75 : 18)
                            }
                        }
                    }
                }
            }
            .navigationTitle(Text(title))
            .navigationBarItems(leading: leadingToolbarControls(), trailing: trailingToolbarControls())
            .onAppear {
                viewModel.reloadList(withSounds: soundData,
                                     andFavorites: try? database.getAllFavorites(),
                                     allowSensitiveContent: UserSettings.getShowOffensiveSounds(),
                                     favoritesOnly: currentMode == .favorites,
                                     sortedBy: SoundSortOption(rawValue: UserSettings.getSoundSortOption()) ?? .titleAscending)
                columns = GridHelper.soundColumns(listWidth: listWidth, sizeCategory: sizeCategory)
                viewModel.donateActivity()
                viewModel.sendUserPersonalTrendsToServerIfEnabled()
                
                if AppPersistentMemory.getHasShownNotificationsOnboarding() == false {
                    subviewToOpen = .onboardingView
                    showingModalView = true
                }
                
                if moveDatabaseIssue.isEmpty == false {
                    viewModel.showMoveDatabaseIssueAlert()
                }
            }
            .sheet(isPresented: $viewModel.showEmailAppPicker_suggestOtherAuthorNameConfirmationDialog) {
                EmailAppPickerView(isBeingShown: $viewModel.showEmailAppPicker_suggestOtherAuthorNameConfirmationDialog, subject: String(format: Shared.suggestOtherAuthorNameEmailSubject, viewModel.selectedSound?.title ?? ""), emailBody: String(format: Shared.suggestOtherAuthorNameEmailBody, viewModel.selectedSound?.authorName ?? "", viewModel.selectedSound?.id ?? ""))
            }
            .sheet(isPresented: $viewModel.showEmailAppPicker_soundUnavailableConfirmationDialog) {
                EmailAppPickerView(isBeingShown: $viewModel.showEmailAppPicker_soundUnavailableConfirmationDialog, subject: Shared.issueSuggestionEmailSubject, emailBody: Shared.issueSuggestionEmailBody)
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
                        try? database.deleteUserFolder(withId: deleteFolderAide.folderIdForDeletion)
                        deleteFolderAide.updateFolderList = true
                        deleteFolderAide.showAlert = false
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
                                    pluralization: .constant(.singular),
                                    selectedSounds: viewModel.selectedSoundsForAddToFolder!)
                    
                case .shareAsVideoView:
                    ShareAsVideoView(viewModel: ShareAsVideoViewViewModel(contentId: viewModel.selectedSound?.id ?? .empty, contentTitle: viewModel.selectedSound?.title ?? .empty, audioFilename: viewModel.selectedSound?.filename ?? .empty), isBeingShown: $showingModalView, result: $shareAsVideo_Result, useLongerGeneratingVideoMessage: false)
                    
                case .settingsView:
                    SettingsCasingWithCloseView(isBeingShown: $showingModalView)
                        .environmentObject(settingsHelper)
                }
            }
            .onReceive(settingsHelper.$updateSoundsList) { shouldUpdate in
                if shouldUpdate {
                    viewModel.reloadList(withSounds: soundData,
                                         andFavorites: try? database.getAllFavorites(),
                                         allowSensitiveContent: UserSettings.getShowOffensiveSounds(),
                                         favoritesOnly: currentMode == .favorites,
                                         sortedBy: SoundSortOption(rawValue: UserSettings.getSoundSortOption()) ?? .titleAscending)
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
            
            if UIDevice.current.userInterfaceIdiom == .phone, searchText.isEmpty {
                VStack {
                    Spacer()

                    floatingSelectorView()
                        .padding()
                }
            }
            
            if shouldDisplayAddedToFolderToast {
                VStack {
                    Spacer()

                    ToastView(text: "Som adicionado à pasta \(folderName ?? "").")
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
        Picker("Exibição", selection: $currentMode) {
            Text("Todos")
                .tag(Mode.allSounds)
            
            Text("Favoritos")
                .tag(Mode.favorites)
            
            Text("Pastas")
                .tag(Mode.folders)
            
            Text("Por Autor")
                .tag(Mode.byAuthor)
        }
        .pickerStyle(.segmented)
        .background(.regularMaterial)
        .cornerRadius(8)
        .onChange(of: currentMode) { currentMode in
            guard currentMode == .allSounds || currentMode == .favorites else {
                return
            }
            viewModel.reloadList(withSounds: soundData,
                                 andFavorites: try? database.getAllFavorites(),
                                 allowSensitiveContent: UserSettings.getShowOffensiveSounds(),
                                 favoritesOnly: currentMode == .favorites,
                                 sortedBy: SoundSortOption(rawValue: UserSettings.getSoundSortOption()) ?? .titleAscending)
        }
    }
    
    @ViewBuilder func leadingToolbarControls() -> some View {
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
    
    @ViewBuilder func trailingToolbarControls() -> some View {
        if currentMode == .folders {
            EmptyView()
        } else {
            HStack(spacing: 15) {
                if currentMode == .byAuthor {
                    Menu {
                        Section {
                            Picker("Ordenação de Autores", selection: $viewModel.authorSortOption) {
                                HStack {
                                    Text("Ordenar por Nome")
                                    Image(systemName: "a.circle")
                                }
                                .tag(0)
                                
                                HStack {
                                    Text("Autores com Mais Sons no Topo")
                                    Image(systemName: "chevron.down.square")
                                }
                                .tag(1)
                                
                                HStack {
                                    Text("Autores com Menos Sons no Topo")
                                    Image(systemName: "chevron.up.square")
                                }
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
                    Menu {
                        Section {
                            Picker("Ordenação de Sons", selection: $viewModel.soundSortOption) {
                                HStack {
                                    Text("Ordenar por Título")
                                    Image(systemName: "a.circle")
                                }
                                .tag(0)
                                
                                HStack {
                                    Text("Ordenar por Nome do Autor")
                                    Image(systemName: "person")
                                }
                                .tag(1)
                                
                                HStack {
                                    Text("Mais Recentes no Topo")
                                    Image(systemName: "calendar")
                                }
                                .tag(2)
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                    .onChange(of: viewModel.soundSortOption, perform: { soundSortOption in
                        viewModel.reloadList(withSounds: soundData,
                                             andFavorites: try? database.getAllFavorites(),
                                             allowSensitiveContent: UserSettings.getShowOffensiveSounds(),
                                             favoritesOnly: currentMode == .favorites,
                                             sortedBy: SoundSortOption(rawValue: soundSortOption) ?? .titleAscending)
                        UserSettings.setSoundSortOption(to: soundSortOption)
                    })
                }
            }
        }
    }
    
    private func shouldScrollToAndHighlight(soundId: String) -> Bool {
        guard soundId.isEmpty == false else {
            return false
        }
        currentMode = .allSounds
        
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
        SoundsView(viewModel: SoundsViewViewModel(soundSortOption: SoundSortOption.dateAddedDescending.rawValue, authorSortOption: AuthorSortOption.nameAscending.rawValue), currentMode: .allSounds)
    }

}
