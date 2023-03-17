//
//  PlaylistList.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 24/02/23.
//

import SwiftUI

struct PlaylistList: View {
    
    @StateObject private var viewModel = PlaylistListViewModel()
    @State private var showAlert: Bool = false
    @State private var newPlaylistName: String = .empty
    @State private var updatePlaylistList: Bool = false
    
    private var noPlaylistsScrollHeight: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            let screenWidth = UIScreen.main.bounds.height
            if screenWidth < 600 {
                return 0
            } else if screenWidth < 800 {
                return 50
            } else {
                return 100
            }
        } else {
            return 100
        }
    }
    
    var body: some View {
        VStack(alignment: .center) {
            if viewModel.hasPlaylistsToDisplay {
                List {
                    ForEach(viewModel.playlists) { playlist in
                        NavigationLink {
                            PlaylistDetailView(viewModel: PlaylistDetailViewViewModel(), playlist: playlist)
                        } label: {
                            PlaylistRow(playlist: playlist)
                        }
                    }
                    .onDelete(perform: delete)
                }
            } else {
                ScrollView {
                    NoPlaylistsView()
                        .padding(.vertical, noPlaylistsScrollHeight)
                }
            }
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
            }
        }
        .alert("Nova playlist", isPresented: $showAlert) {
            TextField("Digite um nome", text: $newPlaylistName)
                .autocorrectionDisabled(true)
            Button("Criar Playlist", action: createNewPlaylist)
            Button("Cancelar",  role: .cancel, action: cancelPlaylistCreation)
        }
        .onAppear {
            viewModel.reloadPlaylistList(withPlaylists: try? database.getAllPlaylists())
        }
        .onChange(of: updatePlaylistList) { updatePlaylistList in
            if updatePlaylistList {
                viewModel.reloadPlaylistList(withPlaylists: try? database.getAllPlaylists())
                self.updatePlaylistList = false
            }
        }
    }
    
    func createNewPlaylist() {
        guard !newPlaylistName.isEmpty else { return }
        try? database.insert(playlist: Playlist(name: newPlaylistName))
        updatePlaylistList = true
        newPlaylistName = .empty
    }
    
    func cancelPlaylistCreation() {
        showAlert = false
        newPlaylistName = .empty
    }
    
    func delete(at offsets: IndexSet) {
        let itemToRemove = offsets.map { index in
            viewModel.playlists[index]
        }
        guard let item = itemToRemove.first else { return }
        try? database.deletePlaylist(withId: item.id)
        updatePlaylistList = true
    }
    
}

struct PlaylistList_Previews: PreviewProvider {
    
    static var previews: some View {
        PlaylistList()
    }
    
}
