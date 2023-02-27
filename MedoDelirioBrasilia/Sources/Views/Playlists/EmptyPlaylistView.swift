//
//  EmptyPlaylistView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 27/02/23.
//

import SwiftUI

struct EmptyPlaylistView: View {
    
    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            Image(systemName: "speaker.wave.3")
                .font(.system(size: 66))
                .foregroundColor(.gray)
                .frame(width: 100)
                .opacity(0.5)
            
            Text("Nenhum Som Adicionado")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
            
            Text("Volte para os sons, segure em um deles e escolha Adicionar a... > Playlist para adicioná-lo aqui.")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .phone ? 15 : 40)
        }
    }
    
}

struct EmptyPlaylistView_Previews: PreviewProvider {
    
    static var previews: some View {
        EmptyPlaylistView()
    }
    
}
