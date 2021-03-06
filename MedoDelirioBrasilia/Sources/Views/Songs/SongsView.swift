import SwiftUI

struct SongsView: View {
    
    @StateObject private var viewModel = SongsViewViewModel()
    @State private var searchText = ""
    @State private var searchBar: UISearchBar?
    
    private var columns: [GridItem] {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return [
                GridItem(.flexible())
            ]
        } else {
            return [
                GridItem(.flexible()),
                GridItem(.flexible())
            ]
        }
    }
    
    var searchResults: [Song] {
        if searchText.isEmpty {
            return viewModel.songs
        } else {
            return viewModel.songs.filter { sound in
                let searchString = sound.title.lowercased().withoutDiacritics()
                return searchString.contains(searchText.lowercased().withoutDiacritics())
            }
        }
    }

    var body: some View {
        ZStack {
            VStack {
                ScrollView {
                    if searchText.isEmpty {
                        HitsMedoDelirioBannerView()
                            .padding(.horizontal)
                            .padding(.vertical, 6)
                    }
                    
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(searchResults) { song in
                            SongCell(songId: song.id, title: song.title, genre: song.genre, duration: song.duration, nowPlaying: $viewModel.nowPlayingKeeper)
                                .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 0 : 5)
                                .onTapGesture {
                                    if viewModel.nowPlayingKeeper.contains(song.id) {
                                        player?.togglePlay()
                                        viewModel.nowPlayingKeeper.removeAll()
                                    } else {
                                        viewModel.playSong(fromPath: song.filename)
                                        viewModel.nowPlayingKeeper.removeAll()
                                        viewModel.nowPlayingKeeper.insert(song.id)
                                    }
                                }
                                .contextMenu(menuItems: {
                                    Section {
                                        Button {
                                            viewModel.shareSong(withPath: song.filename, andContentId: song.id)
                                        } label: {
                                            Label(Shared.shareButtonText, systemImage: "square.and.arrow.up")
                                        }
                                    }
                                    
                                    Section {
                                        Button {
                                            viewModel.selectedSong = song
                                            viewModel.showEmailAppPicker_suggestChangeConfirmationDialog = true
                                        } label: {
                                            Label("Sugerir Altera????o", systemImage: "exclamationmark.bubble")
                                        }
                                    }
                                })
                        }
                    }
                    .searchable(text: $searchText)
                    .disableAutocorrection(true)
                    .padding(.horizontal)
                    .padding(.top, 7)
                    
                    if UserSettings.getShowOffensiveSounds() == false {
                        Text(UIDevice.current.userInterfaceIdiom == .phone ? Shared.contentFilterMessageForSongsiPhone : Shared.contentFilterMessageForSongsiPadMac)
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.top, 15)
                            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 20 : 40)
                    }
                    
                    if searchText.isEmpty {
                        Text("\(viewModel.songs.count) m??sicas. Atualizado em \(songsLastUpdateDate).")
                            .font(.subheadline)
                            .bold()
                            .padding(.top, 10)
                            .padding(.bottom, 18)
                    }
                }
            }
            .navigationTitle("M??sicas")
            .toolbar {
                Menu {
                    Section {
                        Picker("Ordena????o", selection: $viewModel.sortOption) {
                            HStack {
                                Text("Ordenar por T??tulo")
                                Image(systemName: "a.circle")
                            }
                            .tag(0)
                            
                            HStack {
                                Text("Mais Recentes no Topo")
                                Image(systemName: "calendar")
                            }
                            .tag(1)
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                }
                .onChange(of: viewModel.sortOption, perform: { newSortOption in
                    viewModel.reloadList(withSongs: songData,
                                         allowSensitiveContent: UserSettings.getShowOffensiveSounds(),
                                         sortedBy: SongSortOption(rawValue: newSortOption) ?? .titleAscending)
                    UserSettings.setSongSortOption(to: newSortOption)
                })
            }
            .onAppear {
                viewModel.reloadList(withSongs: songData,
                                     allowSensitiveContent: UserSettings.getShowOffensiveSounds(),
                                     sortedBy: SongSortOption(rawValue: UserSettings.getSongSortOption()) ?? .titleAscending)
                viewModel.donateActivity()
            }
            .onDisappear {
                player?.cancel()
                viewModel.nowPlayingKeeper.removeAll()
            }
            .sheet(isPresented: $viewModel.isShowingShareSheet) {
                viewModel.iPadShareSheet
            }
            .sheet(isPresented: $viewModel.showEmailAppPicker_suggestChangeConfirmationDialog) {
                EmailAppPickerView(isBeingShown: $viewModel.showEmailAppPicker_suggestChangeConfirmationDialog,
                                   subject: String(format: Shared.Email.suggestSongChangeSubject, viewModel.selectedSong?.title ?? ""),
                                   emailBody: String(format: Shared.Email.suggestSongChangeBody, viewModel.selectedSong?.id ?? ""))
            }
            
            if viewModel.shouldDisplaySharedSuccessfullyToast {
                VStack {
                    Spacer()
                    
                    ToastView(text: Shared.songSharedSuccessfullyMessage)
                        .padding()
                }
                .transition(.moveAndFade)
            }
        }
    }

}

struct SongsView_Previews: PreviewProvider {

    static var previews: some View {
        SongsView()
    }

}
