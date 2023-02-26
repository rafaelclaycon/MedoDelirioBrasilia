//
//  PlaylistDetailView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 24/02/23.
//

import SwiftUI

struct PlaylistDetailView: View {
    
    private var sounds = [Sound](arrayLiteral: Sound(title: "Test"))
    
    private var columns: [GridItem] {
        [GridItem(.flexible())]
    }
    
    var body: some View {
        VStack {
            LazyVGrid(columns: columns, spacing: UIDevice.current.userInterfaceIdiom == .phone ? 14 : 20) {
                ForEach(sounds) { sound in
                    PlaylistSoundRow(soundId: sound.id, title: sound.title, author: sound.authorName ?? "", duration: sound.duration, nowPlaying: .constant(Set<String>()))
                }
            }
        }
        .toolbar {
            HStack(spacing: 16) {
                Button {
                    print("Repeat tapped")
                } label: {
                    Image(systemName: "repeat")
                }
                
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
        .padding(.horizontal)
    }
    
}

struct PlaylistDetailView_Previews: PreviewProvider {
    
    static var previews: some View {
        PlaylistDetailView()
    }
    
}
