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
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(searchResults) { song in
                            SongCell(songId: song.id, title: song.title, genre: song.genre, duration: song.duration, nowPlaying: $viewModel.nowPlayingKeeper)
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
                                .onLongPressGesture {
                                    TapticFeedback.open()
                                    viewModel.shareSong(withPath: song.filename, andContentId: song.id)
                                }
                        }
                    }
                    .searchable(text: $searchText)
                    .disableAutocorrection(true)
                    .padding(.horizontal)
                    .padding(.top, 7)
                    
                    if UserSettings.getShowOffensiveSounds() == false {
                        Text(Shared.contentFilterMessageForSongs)
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.top, 15)
                            .padding(.horizontal, 20)
                    }
                    
                    if searchText.isEmpty {
                        Text("\(viewModel.songs.count) músicas. Atualizado em \(songsLastUpdateDate).")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.top, 10)
                            .padding(.bottom, 18)
                    }
                }
            }
            .navigationTitle("Músicas")
            .onAppear {
                viewModel.reloadList()
                viewModel.donateActivity()
            }
            .onDisappear {
                player?.cancel()
                viewModel.nowPlayingKeeper.removeAll()
            }
            .sheet(isPresented: $viewModel.isShowingShareSheet) {
                viewModel.iPadShareSheet
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
