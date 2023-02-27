//
//  PlaylistDetailView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 24/02/23.
//

import SwiftUI

struct PlaylistDetailView: View {
    
    @State var playlist: Playlist
    @State private var sounds = [Sound]()
    
    private var columns: [GridItem] {
        [GridItem(.flexible())]
    }
    
    var body: some View {
        VStack {
            List {
                ForEach(Array(sounds.enumerated()), id: \.1) { index, sound in
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
            sounds.append(contentsOf: soundData.shuffled().prefix(10))
        }
        .navigationTitle(playlist.name)
    }
    
    func move(from source: IndexSet, to destination: Int) {
        sounds.move(fromOffsets: source, toOffset: destination)
        for i in 0...(self.sounds.count - 1) {
            self.sounds[i].authorName = authorData.first(where: { $0.id == self.sounds[i].authorId })?.name ?? Shared.unknownAuthor
        }
    }
    
    func delete(at offsets: IndexSet) {
        sounds.remove(atOffsets: offsets)
    }
    
}

struct PlaylistDetailView_Previews: PreviewProvider {
    
    static var previews: some View {
        PlaylistDetailView(playlist: Playlist(name: "Minha Playlist Maravilhosa"))
    }
    
}
