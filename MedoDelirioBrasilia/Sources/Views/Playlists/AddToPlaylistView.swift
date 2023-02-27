//
//  AddToPlaylistView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 26/02/23.
//

import SwiftUI

struct AddToPlaylistView: View {
    
    @StateObject private var viewModel = AddToPlaylistViewViewModel(database: database)
    @Binding var isBeingShown: Bool
    
    @EnvironmentObject var addToPlaylistHelper: AddToPlaylistHelper
    
    @State private var isShowingCreateNewPlaylistAlert: Bool = false
    
    @State private var soundsThatCanBeAdded: [Sound]? = nil
    @State private var playlistForSomeSoundsAlreadyInPlaylist: Playlist? = nil
    
    private let columns = [GridItem(.flexible())]
    
    private func getSoundText() -> String {
        guard let selectedSounds = addToPlaylistHelper.selectedSounds else { return .empty }
        if selectedSounds.count == 1 {
            return "Som:  \(selectedSounds.first!.title)"
        } else {
            return "\(selectedSounds.count) sons selecionados"
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 20) {
                HStack(spacing: 16) {
                    Image(systemName: "speaker.wave.3.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 24)
                        .padding(.leading, 7)

                    Text(getSoundText())
                        .bold()
                        .multilineTextAlignment(.leading)

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 2)

                ScrollView {
                    HStack {
                        Button {
                            isShowingCreateNewPlaylistAlert = true
                        } label: {
                            Text("Criar nova playlist")
                        }

                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 5)

                    HStack {
                        Text("Minhas Playlists")
                            .font(.title2)

                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top)

                    if viewModel.playlists.count == 0 {
                        Text("Nenhuma Playlist")
                            .font(.title2)
                            .foregroundColor(.gray)
                            .padding(.vertical, 200)
                    } else {
                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(viewModel.playlists) { playlist in
                                Button {
                                    addToPlaylistHelper.selectedSounds?.forEach { sound in
                                        try? database.insert(contentId: sound.id, intoPlaylist: playlist.id)
                                    }
                                    
                                    addToPlaylistHelper.playlistName = playlist.name
                                    addToPlaylistHelper.pluralization = addToPlaylistHelper.selectedSounds?.count ?? 0 > 1 ? .plural : .singular
                                    addToPlaylistHelper.hadSuccess = true
                                    isBeingShown = false
                                } label: {
                                    PlaylistRow(playlist: playlist)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Adicionar a Playlist")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading:
                Button("Cancelar") {
                    self.isBeingShown = false
                }
            )
            .onAppear {
                viewModel.reloadFolderList(withPlaylists: try? database.getAllPlaylists())
            }
        }
    }
    
}

struct AddToPlaylistView_Previews: PreviewProvider {
    
    static var previews: some View {
        AddToPlaylistView(isBeingShown: .constant(true))
            .previewDevice(PreviewDevice(rawValue: "iPhone 11"))
    }
    
}
