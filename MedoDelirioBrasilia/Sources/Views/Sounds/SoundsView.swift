import SwiftUI

struct SoundsView: View {

    enum Mode: Int {
        case allSounds, favorites, byAuthor
    }
    
    enum SubviewToOpen {
        case onboardingView, addToFolderView, shareAsVideoView
    }
    
    @StateObject private var viewModel = SoundsViewViewModel()
    @State var currentMode: Mode
    @State private var searchText: String = .empty

    @State private var listWidth: CGFloat = 700
    @State private var columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    @Environment(\.sizeCategory) var sizeCategory

    @State private var scrollViewObject: ScrollViewProxy? = nil
    @State private var subviewToOpen: SubviewToOpen = .onboardingView
    @State private var showingModalView = false
    
    @Binding var updateSoundsList: Bool
    
    // Temporary banners
    //@State private var shouldDisplayHotWheatherBanner: Bool = false
    
    // Add to Folder vars
    @State private var hadSuccessAddingToFolder: Bool = false
    @State private var folderName: String? = nil
    @State private var shouldDisplayAddedToFolderToast: Bool = false
    
    // Share as Video
    @State private var shareAsVideo_Result = ShareAsVideoResult()
    
    // View All Sounds By This Author
    @State var authorToAutoOpen: Author = Author(id: .empty, name: .empty)
    @State var autoOpenAuthor: Bool = false
    
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
        if UIDevice.current.userInterfaceIdiom == .phone {
            if currentMode == .byAuthor {
                return "Autores"
            } else {
                return LocalizableStrings.MainView.title
            }
        } else {
            switch currentMode {
            case .allSounds:
                return "Sons"
            case .favorites:
                return "Favoritos"
            case .byAuthor:
                return "Autores"
            }
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                NavigationLink(destination: AuthorDetailView(author: authorToAutoOpen), isActive: $autoOpenAuthor) { EmptyView() }
                
                if showNoFavoritesView {
                    NoFavoritesView()
                        .padding(.horizontal, 25)
                } else if currentMode == .byAuthor {
                    AuthorsView()
                } else {
                    GeometryReader { geometry in
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: UIDevice.current.userInterfaceIdiom == .phone ? 14 : 20) {
                                ForEach(searchResults) { sound in
                                    SoundCell(soundId: sound.id, title: sound.title, author: sound.authorName ?? "", favorites: $viewModel.favoritesKeeper)
                                        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 20, style: .continuous))
                                        .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 0 : 5)
                                        .onTapGesture {
                                            viewModel.playSound(fromPath: sound.filename)
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
                                                    let hasFolders = try? database.hasAnyUserFolder()
                                                    guard hasFolders ?? false else {
                                                        return viewModel.showNoFoldersAlert()
                                                    }
                                                    subviewToOpen = .addToFolderView
                                                    showingModalView = true
                                                } label: {
                                                    Label(Shared.addToFolderButtonText, systemImage: "folder.badge.plus")
                                                }
                                                .onChange(of: showingModalView) { newValue in
                                                    if (newValue == false) && hadSuccessAddingToFolder {
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
                            .searchable(text: $searchText)
                            .disableAutocorrection(true)
                            .padding(.horizontal)
                            .padding(.top, 7)
                            .onChange(of: geometry.size.width) { newWidth in
                                self.listWidth = newWidth
                                columns = GridHelper.soundColumns(listWidth: listWidth, sizeCategory: sizeCategory)
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
                                    .padding(.bottom, 18)
                            }
                        }
                    }
                }
            }
            .navigationTitle(Text(title))
            .navigationBarItems(leading:
                getLeadingToolbarControl()
            , trailing:
                Menu {
                    Section {
                        Picker("Ordenação", selection: $viewModel.sortOption) {
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
                    
//                    Section {
//                        Button("[DEV ONLY] Rolar até o fim da lista") {
//                            scrollViewObject?.scrollTo(searchResults[searchResults.endIndex - 1])
//                        }
//                    }
                } label: {
                    if UIDevice.current.userInterfaceIdiom == .pad && currentMode == .byAuthor {
                        Text("")
                    } else {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
                .onChange(of: viewModel.sortOption, perform: { newValue in
                    viewModel.reloadList(withSounds: soundData,
                                         andFavorites: try? database.getAllFavorites(),
                                         allowSensitiveContent: UserSettings.getShowOffensiveSounds(),
                                         favoritesOnly: currentMode == .favorites,
                                         sortedBy: SoundSortOption(rawValue: newValue) ?? .titleAscending)
                    UserSettings.setSoundSortOption(to: newValue)
                })
                //.disabled(currentMode == .byAuthor)
            )
            .onAppear {
                viewModel.reloadList(withSounds: soundData,
                                     andFavorites: try? database.getAllFavorites(),
                                     allowSensitiveContent: UserSettings.getShowOffensiveSounds(),
                                     favoritesOnly: currentMode == .favorites,
                                     sortedBy: SoundSortOption(rawValue: UserSettings.getSoundSortOption()) ?? .titleAscending)
                columns = GridHelper.soundColumns(listWidth: listWidth, sizeCategory: sizeCategory)
                viewModel.donateActivity()
                viewModel.sendDeviceModelNameToServer()
                viewModel.sendUserPersonalTrendsToServerIfEnabled()

                /*if AppPersistentMemory.getHasShownNotificationsOnboarding() == false {
                    subviewToOpen = .onboardingView
                    showingModalView = true
                }*/
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
                default:
                    return Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage), primaryButton: .default(Text("Relatar Problema por E-mail"), action: {
                        viewModel.showEmailAppPicker_soundUnavailableConfirmationDialog = true
                    }), secondaryButton: .cancel(Text("Fechar")))
                }
            }
            .sheet(isPresented: $viewModel.isShowingShareSheet) {
                viewModel.iPadShareSheet
            }
            .sheet(isPresented: $showingModalView) {
                switch subviewToOpen {
                 case .onboardingView:
                    OnboardingView(isBeingShown: $showingModalView)
                        .interactiveDismissDisabled(true)
                    
                case .addToFolderView:
                    AddToFolderView(isBeingShown: $showingModalView,
                                    hadSuccess: $hadSuccessAddingToFolder,
                                    folderName: $folderName,
                                    selectedSoundName: viewModel.selectedSound!.title,
                                    selectedSoundId: viewModel.selectedSound!.id)
                    
                case .shareAsVideoView:
                    ShareAsVideoView(viewModel: ShareAsVideoViewViewModel(contentId: viewModel.selectedSound?.id ?? .empty, contentTitle: viewModel.selectedSound?.title ?? .empty, audioFilename: viewModel.selectedSound?.filename ?? .empty), isBeingShown: $showingModalView, result: $shareAsVideo_Result)
                }
            }
            .onChange(of: updateSoundsList) { shouldUpdate in
                if shouldUpdate {
                    viewModel.reloadList(withSounds: soundData,
                                         andFavorites: try? database.getAllFavorites(),
                                         allowSensitiveContent: UserSettings.getShowOffensiveSounds(),
                                         favoritesOnly: currentMode == .favorites,
                                         sortedBy: SoundSortOption(rawValue: UserSettings.getSoundSortOption()) ?? .titleAscending)
                    updateSoundsList = false
                }
            }
            .onChange(of: shareAsVideo_Result.videoFilepath) { videoResultPath in
                if videoResultPath.isEmpty == false {
                    viewModel.shareVideo(withPath: videoResultPath, andContentId: shareAsVideo_Result.contentId)
                }
            }
            
            if shouldDisplayAddedToFolderToast {
                VStack {
                    Spacer()

                    ToastView(text: "Som adicionado à pasta \(folderName ?? "").")
                        .padding()
                }
                .transition(.moveAndFade)
            }
            
            if viewModel.displaySharedSuccessfullyToast {
                VStack {
                    Spacer()
                    
                    ToastView(text: viewModel.shareBannerMessage)
                        .padding()
                }
                .transition(.moveAndFade)
            }
        }
    }
    
    @ViewBuilder func getLeadingToolbarControl() -> some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            Picker("Exibição", selection: $currentMode) {
                Image(systemName: "speaker.wave.3")
                    .tag(Mode.allSounds)
                
                Image(systemName: "star")
                    .tag(Mode.favorites)
                
                Image(systemName: "person")
                    .tag(Mode.byAuthor)
            }
            .pickerStyle(.segmented)
            .frame(width: 200)
            .onChange(of: currentMode) { newValue in
                guard newValue != .byAuthor else {
                    return
                }
                viewModel.reloadList(withSounds: soundData,
                                     andFavorites: try? database.getAllFavorites(),
                                     allowSensitiveContent: UserSettings.getShowOffensiveSounds(),
                                     favoritesOnly: newValue == .favorites,
                                     sortedBy: SoundSortOption(rawValue: UserSettings.getSoundSortOption()) ?? .titleAscending)
            }
        } else {
            EmptyView()
        }
    }

}

struct SoundsView_Previews: PreviewProvider {

    static var previews: some View {
        SoundsView(currentMode: .allSounds, updateSoundsList: .constant(false))
    }

}
