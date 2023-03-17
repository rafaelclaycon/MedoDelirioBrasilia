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
            if viewModel.hasSoundsToDisplay {
                List {
                    ForEach(Array(viewModel.content.enumerated()), id: \.1) { index, content in
                        PlaylistSoundRow(index: index,
                                         soundId: content.sound?.id ?? "",
                                         title: content.sound?.title ?? "",
                                         author: content.sound?.authorName ?? "",
                                         duration: content.sound?.duration ?? 0.0,
                                         nowPlaying: $viewModel.nowPlayingKeeper)
                    }
                    .onMove(perform: move)
                    .onDelete(perform: delete)
                }.moveDisabled(viewModel.isPlayingPlaylist)
            } else {
                ScrollView {
                    EmptyPlaylistView()
                        .padding(.vertical, 100)
                        .padding(.horizontal, 30)
                }
            }
        }
        .toolbar {
            HStack(spacing: 16) {
//                Button {
//                    print("Repeat tapped")
//                } label: {
//                    Image(systemName: "repeat")
//                }.disabled(true)
//
//                Button {
//                    viewModel.sounds.shuffle()
//                } label: {
//                    Image(systemName: "shuffle")
//                }
                
                Button {
                    if viewModel.isPlayingPlaylist {
                        viewModel.stopPlaying()
                    } else {
                        viewModel.playAllSoundsOneAfterTheOther()
                    }
                } label: {
                    Image(systemName: viewModel.isPlayingPlaylist ? "stop.fill" : "play.fill")
                }.disabled(!viewModel.hasSoundsToDisplay)
            }
        }
        .onAppear {
            viewModel.reloadSoundList(withPlaylistContents: try? database.getAllContentsInsidePlaylist(withId: playlist.id))
        }
        .navigationTitle(playlist.name)
    }
    
    func move(from source: IndexSet, to destination: Int) {
        viewModel.content.move(fromOffsets: source, toOffset: destination)
    }
    
    func delete(at offsets: IndexSet) {
        viewModel.content.remove(atOffsets: offsets)
    }
    
}

struct PlaylistDetailView_Previews: PreviewProvider {
    
    static var previews: some View {
        PlaylistDetailView(viewModel: PlaylistDetailViewViewModel(), playlist: Playlist(name: "Minha Playlist Maravilhosa"))
    }
    
}
