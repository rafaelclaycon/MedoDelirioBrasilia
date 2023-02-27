//
//  NoPlaylistsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 26/02/23.
//

import SwiftUI

struct NoPlaylistsView: View {
    
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            Image(systemName: "music.note.list")
                .font(.system(size: 74))
                .foregroundColor(.gray)
            
            Text("Nenhuma Playlist Criada")
                .font(.title3)
                .bold()
                .multilineTextAlignment(.center)
            
            Text("Playlists permitem ordenar sons para reproduzir em sequência, em modo aleatório ou repetindo.")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("\(UIDevice.current.userInterfaceIdiom == .phone ? "Toque no + no canto superior direito para criar uma nova playlist de sons." : "Toque em Nova Playlist acima para criar uma nova playlist de sons.")")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
}

struct NoPlaylistsView_Previews: PreviewProvider {
    
    static var previews: some View {
        NoPlaylistsView()
    }
    
}
