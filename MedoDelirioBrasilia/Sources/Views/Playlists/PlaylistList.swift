//
//  PlaylistList.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 24/02/23.
//

import SwiftUI

struct PlaylistList: View {
    
    @StateObject private var viewModel = PlaylistListViewModel()
    //private var playlists = [Playlist](arrayLiteral: Playlist(name: "Bolsonaro fede"))
    @State private var showAlert = false
    @State private var newPlaylistName = ""
    
    private var columns: [GridItem] {
        [GridItem(.flexible())]
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                if viewModel.hasPlaylistsToDisplay {
                    LazyVGrid(columns: columns, spacing: 24) {
                        ForEach(viewModel.playlists) { playlist in
                            NavigationLink {
                                PlaylistDetailView(viewModel: PlaylistDetailViewViewModel(), playlist: playlist)
                            } label: {
                                PlaylistRow(playlist: playlist)
                            }
                            //.foregroundColor(.primary)
                        }
                    }
                } else {
                    NoPlaylistsView()
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)
            .padding(.bottom, 18)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAlert = true
                } label: {
                    HStack {
                        Image(systemName: "plus")
                    }
                }
//                .onChange(of: isShowingFolderInfoEditingSheet) { isShowing in
//                    if isShowing == false {
//                        updateFolderList = true
//                        folderForEditingOnSheet = nil
//                    }
//                }
            }
        }
        .alert("Nova playlist", isPresented: $showAlert) {
            TextField("Digite um nome", text: $newPlaylistName)
            Button("Criar Playlist", action: createNewPlaylist)
            Button("Cancelar",  role: .cancel, action: cancelPlaylistCreation)
        }
        .onAppear {
            viewModel.reloadPlaylistList(withPlaylists: try? database.getAllPlaylists())
        }
    }
    
    func createNewPlaylist() {
        guard !newPlaylistName.isEmpty else { return }
        try? database.insert(playlist: Playlist(name: newPlaylistName))
        newPlaylistName = .empty
    }
    
    func cancelPlaylistCreation() {
        showAlert = false
        newPlaylistName = .empty
    }
    
}

struct PlaylistList_Previews: PreviewProvider {
    
    static var previews: some View {
        PlaylistList()
    }
    
}
