//
//  PlaylistDetailView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 24/02/23.
//

import SwiftUI

struct PlaylistDetailView: View {
    
    @StateObject var viewModel: PlaylistDetailViewViewModel
    @State var playlist: Playlist
    
    var body: some View {
        VStack {
            List {
                ForEach(Array(viewModel.sounds.enumerated()), id: \.1) { index, sound in
                    PlaylistSoundRow(index: index, soundId: sound.id, title: sound.title, author: sound.authorName ?? "", duration: sound.duration, nowPlaying: .constant(Set<String>()))
                }
                .onMove(perform: move)
                .onDelete(perform: delete)
            }
        }
        .toolbar {
            HStack(spacing: 16) {
                Button {
                    print("Repeat tapped")
                } label: {
                    Image(systemName: "repeat")
                }.disabled(true)
                
                Button {
                    print("Shuffle tapped")
                } label: {
                    Image(systemName: "shuffle")
                }
                
                Button {
                    print("Play tapped")
                } label: {
                    Image(systemName: "play.fill")
                }
            }
        }
        .onAppear {
            viewModel.reloadSoundList(withPlaylistContents: try? database.getAllContentsInsidePlaylist(withId: playlist.id))
        }
        .navigationTitle(playlist.name)
    }
    
    func move(from source: IndexSet, to destination: Int) {
        viewModel.sounds.move(fromOffsets: source, toOffset: destination)
    }
    
    func delete(at offsets: IndexSet) {
        viewModel.sounds.remove(atOffsets: offsets)
    }
    
}

struct PlaylistDetailView_Previews: PreviewProvider {
    
    static var previews: some View {
        PlaylistDetailView(viewModel: PlaylistDetailViewViewModel(), playlist: Playlist(name: "Minha Playlist Maravilhosa"))
    }
    
}
