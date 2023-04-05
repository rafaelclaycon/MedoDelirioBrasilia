//
//  NoFavoritesView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 26/05/22.
//

import SwiftUI

struct NoFavoritesView: View {

    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            Image(systemName: "star")
                .font(.system(size: 74))
                .foregroundColor(.red)
            
            Text("Nenhum Favorito")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)
            
            Text("Para adicionar um som aos Favoritos, volte para os sons, segure em um deles e escolha Adicionar aos Favoritos.")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("Para adicionar vários, escolha Selecionar no menu do canto superior direito, toque nos sons que quer favoritar e então na estrela que aparecerá ao lado do menu.")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }

}

struct NoFavoritesView_Previews: PreviewProvider {

    static var previews: some View {
        NoFavoritesView()
    }

}
