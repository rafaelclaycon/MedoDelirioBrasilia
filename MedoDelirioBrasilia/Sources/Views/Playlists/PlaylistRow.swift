//
//  PlaylistRow.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 24/02/23.
//

import SwiftUI

struct PlaylistRow: View {
    
    @State var playlist: Playlist
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "music.note.list")
                .font(.system(size: 22))
            
            Text(playlist.name)
                .font(.body)
            
            Spacer()
        }
    }
    
}

struct PlaylistRow_Previews: PreviewProvider {
    
    static var previews: some View {
        PlaylistRow(playlist: Playlist(name: "Test"))
    }
    
}