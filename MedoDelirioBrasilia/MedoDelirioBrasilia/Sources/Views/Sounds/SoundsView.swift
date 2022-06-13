import SwiftUI

struct SoundsView: View {

    @StateObject private var viewModel = SoundsViewViewModel()
    @State private var showingHelpScreen = false
    @State private var searchText = ""
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var searchResults: [Sound] {
        if searchText.isEmpty {
            return viewModel.sounds
        } else {
            return viewModel.sounds.filter { sound in
                let searchString = "\(sound.description.lowercased().withoutDiacritics()) \(sound.authorName?.lowercased().withoutDiacritics() ?? "")"
                return searchString.contains(searchText.lowercased().withoutDiacritics())
            }
        }
    }
    
    var showNoFavoritesView: Bool {
        searchResults.isEmpty && viewModel.showOnlyFavorites
    }
    
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: SoundHelpView(), isActive: $showingHelpScreen) { EmptyView() }
                
                if showNoFavoritesView {
                    NoFavoritesView()
                        .padding(.horizontal, 25)
                } else {
                    ScrollView {
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
                        
                        if UserSettings.getShowOffensiveSounds() == false, viewModel.showOnlyFavorites == false {
                            Text("Filtrando conteúdo sensível. Você pode mudar isso na aba Ajustes.")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.top, 15)
                                .padding(.horizontal, 20)
                        }
                        
                        if searchText.isEmpty, viewModel.showOnlyFavorites == false {
                            Text("\(viewModel.sounds.count) sons. Atualizado em \(soundsLastUpdateDate).")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.top, 10)
                                .padding(.bottom, 18)
                        }
                    }
                }
            }
            .navigationTitle(Text(LocalizableStrings.MainView.title))
            .navigationBarItems(leading:
                HStack {
                    Button(action: {
                        showingHelpScreen = true
                    }) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                        }
                    }
                    Button(action: {
                        viewModel.showOnlyFavorites.toggle()
                    }) {
                        HStack {
                            Image(systemName: viewModel.showOnlyFavorites ? "star.fill" : "star")
                        }
                    }
                    .onChange(of: viewModel.showOnlyFavorites) { newValue in
                        viewModel.reloadList(withSounds: soundData,
                                             andFavorites: try? database.getAllFavorites(),
                                             allowSensitiveContent: UserSettings.getShowOffensiveSounds(),
                                             favoritesOnly: newValue,
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
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                }
                .onChange(of: viewModel.sortOption, perform: { newValue in
                    viewModel.reloadList(withSounds: soundData,
                                         andFavorites: try? database.getAllFavorites(),
                                         allowSensitiveContent: UserSettings.getShowOffensiveSounds(),
                                         favoritesOnly: viewModel.showOnlyFavorites,
                                         sortedBy: ContentSortOption(rawValue: newValue) ?? .titleAscending)
                    UserSettings.setSoundSortOption(to: newValue)
                })
            )
            .onAppear {
                viewModel.reloadList(withSounds: soundData,
                                     andFavorites: try? database.getAllFavorites(),
                                     allowSensitiveContent: UserSettings.getShowOffensiveSounds(),
                                     favoritesOnly: viewModel.showOnlyFavorites,
                                     sortedBy: ContentSortOption(rawValue: UserSettings.getSoundSortOption()) ?? .titleAscending)
                viewModel.donateActivity()
                viewModel.sendDeviceModelNameToServer()
            }
            .confirmationDialog("", isPresented: $viewModel.showConfirmationDialog) {
                Button(viewModel.getFavoriteButtonTitle()) {
                    guard let sound = viewModel.soundForConfirmationDialog else {
                        return
                    }
                    if viewModel.isSelectedSoundAlreadyAFavorite() {
                        viewModel.removeFromFavorites(soundId: sound.id)
                        if viewModel.showOnlyFavorites {
                            viewModel.reloadList(withSounds: soundData,
                                                 andFavorites: try? database.getAllFavorites(),
                                                 allowSensitiveContent: UserSettings.getShowOffensiveSounds(),
                                                 favoritesOnly: viewModel.showOnlyFavorites,
                                                 sortedBy: ContentSortOption(rawValue: UserSettings.getSoundSortOption()) ?? .titleAscending)
                        }
                    } else {
                        viewModel.addToFavorites(soundId: sound.id)
                    }
                }
                
                Button(SoundOptionsHelper.getSuggestOtherAuthorNameButtonTitle(authorId: viewModel.soundForConfirmationDialog?.authorId ?? .empty)) {
                    guard let sound = viewModel.soundForConfirmationDialog else {
                        return
                    }
                    SoundOptionsHelper.suggestOtherAuthorName(soundId: sound.id, soundTitle: sound.title, currentAuthorName: sound.authorName ?? .empty)
                }
                
                Button("Compartilhar") {
                    guard let sound = viewModel.soundForConfirmationDialog else {
                        return
                    }
                    viewModel.shareSound(withPath: sound.filename, andContentId: sound.id)
                }
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text(viewModel.alertTitle), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

}

struct SoundsView_Previews: PreviewProvider {

    static var previews: some View {
        SoundsView()
    }

}
