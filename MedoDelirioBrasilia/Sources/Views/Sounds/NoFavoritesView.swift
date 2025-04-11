//
//  NoFavoritesView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 26/05/22.
//

import SwiftUI

struct NoFavoritesView: View {

    var body: some View {
        VStack(alignment: .center, spacing: .spacing(.xLarge)) {
            Image(systemName: "star")
                .font(.system(size: 74))
                .foregroundColor(.red)
            
            Text("Nenhum Favorito")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)
            
            Text("Para adicionar um conteúdo aos Favoritos, volte para Tudo, segure em um deles e escolha **Adicionar aos Favoritos**.")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("Para adicionar vários, escolha **Selecionar** no menu do canto superior direito.")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

// MARK: - Preview

#Preview {
    NoFavoritesView()
}
