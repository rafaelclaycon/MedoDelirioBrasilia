import SwiftUI

struct SoundsView: View {

    enum Mode: Int {
        case allSounds, favorites, byAuthor
    }
    
    @StateObject private var viewModel = SoundsViewViewModel()
    @State var currentMode: Mode
    @State private var searchText = ""
    @State private var scrollViewObject: ScrollViewProxy? = nil
    
    @Binding var updateSoundsList: Bool
    
    // Temporary banners
    @State private var shouldDisplayHotWheatherBanner: Bool = false
    
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
                            if shouldDisplayHotWheatherBanner, searchText.isEmpty, currentMode != .favorites {
                                HotWeatherAdBannerView(displayMe: $shouldDisplayHotWheatherBanner)
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
                                            Section {
                                                Button {
                                                    viewModel.shareSound(withPath: sound.filename, andContentId: sound.id)
                                                } label: {
                                                    Label(Shared.shareButtonText, systemImage: "square.and.arrow.up")
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
                                                                                 sortedBy: ContentSortOption(rawValue: UserSettings.getSoundSortOption()) ?? .titleAscending)
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
                                                    showingAddToFolderModal = true
                                                } label: {
                                                    Label(Shared.addToFolderButtonText, systemImage: "folder.badge.plus")
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
                                            }
                                            
                                            Section {
                                                Button {
                                                    viewModel.selectedSound = sound
                                                    viewModel.showEmailAppPicker_suggestOtherAuthorNameConfirmationDialog = true
                                                } label: {
                                                    Label(SoundOptionsHelper.getSuggestOtherAuthorNameButtonTitle(authorId: sound.authorId), systemImage: "exclamationmark.bubble")
                                                }
                                            }
                                            
//                                            Button {
//                                                //
//                                            } label: {
//                                                Label("Ver Todos os Sons Desse Autor", systemImage: "person")
//                                            }
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
                HStack {
                    Menu {
                        Section {
                            Picker("Exibição", selection: $currentMode) {
                                HStack {
                                    Text("Todos os Sons")
                                    Image(systemName: "speaker.wave.3")
                                }
                                .tag(Mode.allSounds)
                                
                                HStack {
                                    Text("Favoritos")
                                    Image(systemName: "star")
                                }
                                .tag(Mode.favorites)
                                
                                HStack {
                                    Text("Agrupados por Autor")
                                    Image(systemName: "person")
                                }
                                .tag(Mode.byAuthor)
                            }
                        }
                    } label: {
                        if UIDevice.current.userInterfaceIdiom == .pad {
                            Text("")
                        } else {
                            HStack {
                                Text(dropDownText)
                                Image(systemName: "chevron.down")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15)
                            }
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
                .disabled(UIDevice.current.userInterfaceIdiom == .pad)
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
                
                shouldDisplayHotWheatherBanner = UserSettings.getHotWeatherBannerWasDismissed() == false
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
            .sheet(isPresented: $showingAddToFolderModal) {
                AddToFolderView(isBeingShown: $showingAddToFolderModal, hadSuccess: $hadSuccessAddingToFolder, folderName: $folderName, selectedSoundName: viewModel.selectedSound!.title, selectedSoundId: viewModel.selectedSound!.id)
            }
            .sheet(isPresented: $viewModel.isShowingShareSheet) {
                viewModel.iPadShareSheet
            }
            .onChange(of: updateSoundsList) { shouldUpdate in
                if shouldUpdate {
                    viewModel.reloadList(withSounds: soundData,
                                         andFavorites: try? database.getAllFavorites(),
                                         allowSensitiveContent: UserSettings.getShowOffensiveSounds(),
                                         favoritesOnly: currentMode == .favorites,
                                         sortedBy: ContentSortOption(rawValue: UserSettings.getSoundSortOption()) ?? .titleAscending)
                    updateSoundsList = false
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

struct SoundsView_Previews: PreviewProvider {

    static var previews: some View {
        SoundsView(currentMode: .allSounds, updateSoundsList: .constant(false))
    }

}
