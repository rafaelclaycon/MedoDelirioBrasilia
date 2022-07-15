import SwiftUI

struct SoundsView: View {

    enum Mode: Int {
        case allSounds, favorites, byAuthor
    }
    
    @StateObject private var viewModel = SoundsViewViewModel()
    @State private var currentMode: Mode = .allSounds
    @State private var searchText = ""
    @State private var scrollViewObject: ScrollViewProxy? = nil
    
    // Temporary banners
    @State private var shouldDisplayFolderBanner: Bool = false
    
    // Add to Folder vars
    @State private var showingAddToFolderModal = false
    @State private var hadSuccessAddingToFolder: Bool = false
    @State private var folderName: String? = nil
    @State private var shouldDisplayAddedToFolderToast: Bool = false
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
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
    
    private var dropDownText: String {
        switch currentMode {
        case .allSounds:
            return "Todos"
        case .favorites:
            return "Favoritos"
        case .byAuthor:
            return "Por autor"
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    if showNoFavoritesView {
                        NoFavoritesView()
                            .padding(.horizontal, 25)
                    } else if currentMode == .byAuthor {
                        AuthorsView()
                    } else {
                        ScrollViewReader { scrollView in
                            ScrollView {
                                if shouldDisplayFolderBanner, searchText.isEmpty, currentMode != .favorites {
                                    FoldersBannerView(displayMe: $shouldDisplayFolderBanner)
                                        .padding(.horizontal)
                                        .padding(.vertical, 6)
                                }
                                
                                LazyVGrid(columns: columns, spacing: 14) {
                                    ForEach(searchResults) { sound in
                                        SoundCell(soundId: sound.id, title: sound.title, author: sound.authorName ?? "", favorites: $viewModel.favoritesKeeper)
                                            .onTapGesture {
                                                viewModel.playSound(fromPath: sound.filename)
                                            }
                                            .onLongPressGesture {
                                                viewModel.soundForConfirmationDialog = sound
                                                viewModel.showConfirmationDialog = true
                                            }
                                    }
                                }
                                .searchable(text: $searchText)
                                .disableAutocorrection(true)
                                .padding(.horizontal)
                                .padding(.top, 7)
                                .onAppear {
                                    scrollViewObject = scrollView
                                }
                                
                                if UserSettings.getShowOffensiveSounds() == false, currentMode != .favorites {
                                    Text(Shared.contentFilterMessageForSounds)
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                        .padding(.top, 15)
                                        .padding(.horizontal, 20)
                                }
                                
                                if searchText.isEmpty, currentMode != .favorites {
                                    Text("\(viewModel.sounds.count) sons. Atualizado em \(soundsLastUpdateDate).")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .padding(.top, 10)
                                        .padding(.bottom, 18)
                                }
                            }
                        }
                    }
                }
                .navigationTitle(Text(LocalizableStrings.MainView.title))
                .navigationBarItems(leading:
                    HStack {
                        Menu {
                            Section {
                                Picker(selection: $currentMode, label: Text("Exibição")) {
                                    Text("Todos os sons")
                                        .tag(Mode.allSounds)

                                    Text("Favoritos")
                                        .tag(Mode.favorites)

                                    Text("Agrupados por autor")
                                        .tag(Mode.byAuthor)
                                }
                            }
                        } label: {
                            HStack {
                                Text(dropDownText)
                                Image(systemName: "chevron.down")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15)
                            }
                        }
                        .onChange(of: currentMode) { newValue in
                            guard newValue != .byAuthor else {
                                return
                            }
                            viewModel.reloadList(withSounds: soundData,
                                                 andFavorites: try? database.getAllFavorites(),
                                                 allowSensitiveContent: UserSettings.getShowOffensiveSounds(),
                                                 favoritesOnly: newValue == .favorites,
                                                 sortedBy: ContentSortOption(rawValue: UserSettings.getSoundSortOption()) ?? .titleAscending)
                        }
                    }
                , trailing:
                    Menu {
                        Section {
                            Picker(selection: $viewModel.sortOption, label: Text("Ordenação")) {
                                Text("Ordenar por Título")
                                    .tag(0)

                                Text("Ordenar por Nome do Autor")
                                    .tag(1)

                                Text("Mais Recentes no Topo")
                                    .tag(2)
                            }
                        }
                        
    //                    Section {
    //                        Button("[DEV ONLY] Rolar até o fim da lista") {
    //                            scrollViewObject?.scrollTo(searchResults[searchResults.endIndex - 1])
    //                        }
    //                    }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                    .onChange(of: viewModel.sortOption, perform: { newValue in
                        viewModel.reloadList(withSounds: soundData,
                                             andFavorites: try? database.getAllFavorites(),
                                             allowSensitiveContent: UserSettings.getShowOffensiveSounds(),
                                             favoritesOnly: currentMode == .favorites,
                                             sortedBy: ContentSortOption(rawValue: newValue) ?? .titleAscending)
                        UserSettings.setSoundSortOption(to: newValue)
                    })
                    .disabled(currentMode == .byAuthor)
                )
                .onAppear {
                    viewModel.reloadList(withSounds: soundData,
                                         andFavorites: try? database.getAllFavorites(),
                                         allowSensitiveContent: UserSettings.getShowOffensiveSounds(),
                                         favoritesOnly: currentMode == .favorites,
                                         sortedBy: ContentSortOption(rawValue: UserSettings.getSoundSortOption()) ?? .titleAscending)
                    viewModel.donateActivity()
                    viewModel.sendDeviceModelNameToServer()
                    viewModel.sendUserPersonalTrendsToServerIfEnabled()
                    shouldDisplayFolderBanner = UserSettings.getFolderBannerWasDismissed() == false
                }
                .confirmationDialog("", isPresented: $viewModel.showConfirmationDialog) {
                    Button(viewModel.getFavoriteButtonTitle()) {
                        guard let sound = viewModel.soundForConfirmationDialog else {
                            return
                        }
                        if viewModel.isSelectedSoundAlreadyAFavorite() {
                            viewModel.removeFromFavorites(soundId: sound.id)
                            if currentMode == .favorites {
                                viewModel.reloadList(withSounds: soundData,
                                                     andFavorites: try? database.getAllFavorites(),
                                                     allowSensitiveContent: UserSettings.getShowOffensiveSounds(),
                                                     favoritesOnly: currentMode == .favorites,
                                                     sortedBy: ContentSortOption(rawValue: UserSettings.getSoundSortOption()) ?? .titleAscending)
                            }
                        } else {
                            viewModel.addToFavorites(soundId: sound.id)
                        }
                    }
                    
                    Button(Shared.addToFolderButtonText) {
                        let hasFolders = try? database.hasAnyUserFolder()
                        guard hasFolders ?? false else {
                            return viewModel.showNoFoldersAlert()
                        }
                        guard viewModel.soundForConfirmationDialog != nil else {
                            return
                        }
                        showingAddToFolderModal = true
                    }
                    .onChange(of: showingAddToFolderModal) { newValue in
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
                    
//                    Button("👱  Ver Todos os Sons Desse Autor") {
//                        print("Ver autor")
//                    }
                    
                    Button(SoundOptionsHelper.getSuggestOtherAuthorNameButtonTitle(authorId: viewModel.soundForConfirmationDialog?.authorId ?? .empty)) {
                        guard let sound = viewModel.soundForConfirmationDialog else {
                            return
                        }
                        SoundOptionsHelper.suggestOtherAuthorName(soundId: sound.id, soundTitle: sound.title, currentAuthorName: sound.authorName ?? .empty)
                    }
                    
                    Button(Shared.shareButtonText) {
                        guard let sound = viewModel.soundForConfirmationDialog else {
                            return
                        }
                        viewModel.shareSound(withPath: sound.filename, andContentId: sound.id)
                    }
                }
                .confirmationDialog(Shared.pickAMailApp, isPresented: $viewModel.showEmailClientConfirmationDialog, titleVisibility: .visible) {
                    Mailman.getMailClientOptions()
                }
                .alert(isPresented: $viewModel.showAlert) {
                    switch viewModel.alertType {
                    case .singleOption:
                        return Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
                    default:
                        return Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage), primaryButton: .default(Text("Relatar Problema por E-mail"), action: {
                            viewModel.showEmailClientConfirmationDialog = true
                        }), secondaryButton: .cancel(Text("Fechar")))
                    }
                }
                .sheet(isPresented: $showingAddToFolderModal) {
                    AddToFolderView(isBeingShown: $showingAddToFolderModal, hadSuccess: $hadSuccessAddingToFolder, folderName: $folderName, selectedSoundName: viewModel.soundForConfirmationDialog!.title, selectedSoundId: viewModel.soundForConfirmationDialog!.id)
                }
                .onChange(of: viewModel.showConfirmationDialog) { show in
                    if show {
                        TapticFeedback.open()
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
                
                if viewModel.shouldDisplaySharedSuccessfullyToast {
                    VStack {
                        Spacer()
                        
                        ToastView(text: Shared.soundSharedSuccessfullyMessage)
                            .padding()
                    }
                    .transition(.moveAndFade)
                }
            }
        }
    }

}

struct SoundsView_Previews: PreviewProvider {

    static var previews: some View {
        SoundsView()
    }

}
