//
//  HelpView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 21/05/22.
//

import SwiftUI

struct HelpView: View {
    
    private let iconFrameWidth: CGFloat = 40
    
    private var toPlayInstruction: String {
        if ProcessInfo.processInfo.isMacCatalystApp {
            return "Para reproduzir um som, clique nele 1 vez."
        } else {
            return "Para reproduzir um som, toque nele 1 vez."
        }
    }
    
    private var toShareInstruction: String {
        if ProcessInfo.processInfo.isMacCatalystApp {
            return "Para compartilhar, clique com o botão direito no som e escolha Compartilhar Som."
        } else {
            return "Para compartilhar, segure o som e escolha Compartilhar Som."
        }
    }
    
    private var toSearchInstruction: String {
        if ProcessInfo.processInfo.isMacCatalystApp {
            return "Para pesquisar, clique no campo Buscar no canto superior direito da tela de sons e digite o texto que procura.\n\nA pesquisa considera o conteúdo do áudio e o nome do autor. Não use vírgulas."
        } else {
            if UIDevice.current.userInterfaceIdiom == .phone {
                return "Para pesquisar, vá até o topo da lista de sons e puxe mais um pouco para baixo até revelar o campo Buscar.\n\nA pesquisa considera o conteúdo do áudio e o nome do autor. Não use vírgulas."
            } else {
                return "Para pesquisar, toque no campo Buscar no canto superior direito da tela de sons e digite o texto que procura.\n\nA pesquisa considera o conteúdo do áudio e o nome do autor. Não use vírgulas."
            }
        }
    }
    
    private var favoritesInstruction: String {
        if ProcessInfo.processInfo.isMacCatalystApp {
            return "Para favoritar, clique com o botão direito em um som e escolha Adicionar aos Favoritos.\n\nPara ver apenas os favoritos, clique em Favoritos na barra lateral.\n\nÉ possível pesquisar entre os favoritos usando o campo de Busca no topo direito da tela de Favoritos."
        } else {
            if UIDevice.current.userInterfaceIdiom == .phone {
                return "Para favoritar, segure o som e escolha Adicionar aos Favoritos.\n\nPara ver apenas os favoritos, na aba Sons, toque na estrela no topo da tela para trocar para a visão de Favoritos.\n\nÉ possível pesquisar entre os favoritos usando a barra de Busca. Para isso, na lista de favoritos, vá até o topo e puxe mais um pouco para baixo até ver a barra."
            } else {
                return "Para favoritar, segure o som e escolha Adicionar aos Favoritos.\n\nPara ver apenas os favoritos, toque em Favoritos na barra lateral.\n\nÉ possível pesquisar entre os favoritos usando o campo de Busca no topo direito da tela de Favoritos."
            }
        }
    }

    var body: some View {
        VStack {
            ScrollView {                
                VStack(alignment: .leading, spacing: 30) {
                    HStack {
                        Text("Sons")
                            .font(.title)
                        
                        Spacer()
                    }
                    
                    HStack(alignment: .center, spacing: 15) {
                        Image(systemName: "play.fill")
                            .font(.largeTitle)
                            .foregroundColor(.accentColor)
                            .frame(width: iconFrameWidth)
                        
                        Text(toPlayInstruction)
                    }
                    
                    HStack(alignment: .center, spacing: 15) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.largeTitle)
                            .foregroundColor(.accentColor)
                            .frame(width: iconFrameWidth)
                        
                        Text(toShareInstruction)
                    }
                    
                    Divider()
                    
                    HStack(alignment: .center, spacing: 15) {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                            .foregroundColor(.accentColor)
                            .frame(width: iconFrameWidth)
                        
                        Text(toSearchInstruction)
                    }
                    
                    Divider()
                    
                    HStack(alignment: .center, spacing: 15) {
                        Image(systemName: "star.fill")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                            .frame(width: iconFrameWidth)

                        Text(favoritesInstruction)
                    }
                    
                    HStack {
                        Text("Músicas")
                            .font(.title)

                        Spacer()
                    }
                    
                    SongHelpView()
                        .padding(.bottom, 15)
                }
                .padding()
            }
        }
        .navigationTitle("Ajuda")
        //.navigationBarTitleDisplayMode(.inline)
    }

}

struct SoundHelpView_Previews: PreviewProvider {

    static var previews: some View {
        HelpView()
    }

}
