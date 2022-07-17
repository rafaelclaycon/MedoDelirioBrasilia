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
    
    private var columns: [GridItem] {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return [
                GridItem(.flexible()),
                GridItem(.flexible())
            ]
        } else {
            return [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ]
        }
    }
    
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
    
    private var title: String {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return LocalizableStrings.MainView.title
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
                            
                            LazyVGrid(columns: columns, spacing: UIDevice.current.userInterfaceIdiom == .phone ? 14 : 20) {
                                ForEach(searchResults) { sound in
                                    SoundCell(soundId: sound.id, title: sound.title, author: sound.authorName ?? "", favorites: $viewModel.favoritesKeeper)
                                        .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 0 : 5)
                                        .onTapGesture {
                                            viewModel.playSound(fromPath: sound.filename)
                                        }
                                        .contextMenu(menuItems: {
                                            Button(action: {
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
                                            }, label: {
                                                Label(viewModel.getFavoriteButtonTitle(), systemImage: "star")
                                            })
                                            
                                            Button(action: {
                                                let hasFolders = try? database.hasAnyUserFolder()
                                                guard hasFolders ?? false else {
                                                    return viewModel.showNoFoldersAlert()
                                                }
                                                showingAddToFolderModal = true
                                            }, label: {
                                                Label(Shared.addToFolderButtonText, systemImage: "folder.badge.plus")
                                            })
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
                                            
                                            Button(action: {
                                                viewModel.soundForConfirmationDialog = sound
                                                viewModel.showEmailAppPicker_suggestOtherAuthorNameConfirmationDialog = true
                                            }, label: {
                                                Label(SoundOptionsHelper.getSuggestOtherAuthorNameButtonTitle(authorId: sound.authorId), systemImage: "exclamationmark.bubble")
                                            })
                                            
//                                            Button(action: {
//                                                //
//                                            }, label: {
//                                                Label("Ver Todos os Sons Desse Autor", systemImage: "person")
//                                            })
                                            
                                            Button(action: {
                                                viewModel.shareSound(withPath: sound.filename, andContentId: sound.id)
                                            }, label: {
                                                Label(Shared.shareButtonText, systemImage: "square.and.arrow.up")
                                            })
                                        })
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
            .navigationTitle(Text(title))
            .navigationBarItems(leading:
                HStack {
                    Menu {
                        Section {
                            Picker(selection: $currentMode, label: Text("Exibição")) {
                                HStack {
                                    Text("Todos os sons")
                                    Image(systemName: "speaker.wave.3")
                                }
                                .tag(Mode.allSounds)
                                
                                HStack {
                                    Text("Favoritos")
                                    Image(systemName: "star")
                                }
                                .tag(Mode.favorites)
                                
                                HStack {
                                    Text("Agrupados por autor")
                                    Image(systemName: "person")
                                }
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
            .confirmationDialog(Shared.pickAMailApp, isPresented: $viewModel.showEmailAppPicker_suggestOtherAuthorNameConfirmationDialog, titleVisibility: .visible) {
                Mailman.getMailClientOptions(subject: String(format: Shared.suggestOtherAuthorNameEmailSubject, viewModel.soundForConfirmationDialog?.title ?? ""),
                                             body: String(format: Shared.suggestOtherAuthorNameEmailBody, viewModel.soundForConfirmationDialog?.authorName ?? "", viewModel.soundForConfirmationDialog?.id ?? ""))
            }
            .confirmationDialog(Shared.pickAMailApp, isPresented: $viewModel.showEmailAppPicker_soundUnavailableConfirmationDialog, titleVisibility: .visible) {
                Mailman.getMailClientOptions(subject: Shared.issueSuggestionEmailSubject, body: Shared.issueSuggestionEmailBody)
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
            .sheet(isPresented: $showingAddToFolderModal) {
                AddToFolderView(isBeingShown: $showingAddToFolderModal, hadSuccess: $hadSuccessAddingToFolder, folderName: $folderName, selectedSoundName: viewModel.soundForConfirmationDialog!.title, selectedSoundId: viewModel.soundForConfirmationDialog!.id)
            }
            .sheet(isPresented: $viewModel.isShowingShareSheet) {
                viewModel.iPadShareSheet
            }
            // .onChange(of: viewModel.showConfirmationDialog) { show in
            //     if show {
            //         TapticFeedback.open()
            //     }
            // }
            
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

struct SoundsView_Previews: PreviewProvider {

    static var previews: some View {
        SoundsView()
    }

}
