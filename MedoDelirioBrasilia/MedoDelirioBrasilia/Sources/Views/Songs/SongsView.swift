import SwiftUI

struct SongsView: View {
    
    @StateObject private var viewModel = SongsViewViewModel()
    @State private var showingHelpScreen = false
    @State private var searchText = ""
    @State private var searchBar: UISearchBar?
    
    let columns = [
        GridItem(.flexible())
    ]
    
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
        NavigationView {
            VStack {
                NavigationLink(destination: SongHelpView(), isActive: $showingHelpScreen) { EmptyView() }
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(searchResults) { song in
                            SongCell(songId: song.id, title: song.title, nowPlaying: $viewModel.nowPlayingKeeper)
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
                                    viewModel.shareSong(withPath: song.filename, andContentId: song.id)
                                }
                        }
                    }
                    .searchable(text: $searchText)
                    .padding(.horizontal)
                    .padding(.top, 7)
                    
                    if UserSettings.getShowOffensiveSounds() == false {
                        Text("Filtrando conteúdo sensível. Você pode mudar isso na aba Ajustes.")
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
            .navigationBarItems(leading:
                Button(action: {
                    showingHelpScreen = true
                }) {
                    HStack {
                        Image(systemName: "questionmark.circle")
                    }
                }
            )
            .onAppear {
                viewModel.reloadList()
                viewModel.donateActivity()
            }
        }
    }

}

struct SongsView_Previews: PreviewProvider {

    static var previews: some View {
        SongsView()
    }

}
