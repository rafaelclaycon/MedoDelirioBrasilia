//
//  HelpView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 21/05/22.
//

import SwiftUI

struct HelpView: View {

    var body: some View {
        VStack {
            ScrollView {                
                VStack(alignment: .leading, spacing: .spacing(.xxLarge)) {
                    Text("Sons & Músicas")
                        .font(.title)
                        .bold()

                    HelpInstructionView(
                        symbol: "play.fill",
                        text: toPlayInstruction
                    )

                    HelpInstructionView(
                        symbol: "square.and.arrow.up",
                        text: toShareInstruction
                    )
                    
                    Divider()

                    HelpInstructionView(
                        symbol: "magnifyingglass",
                        text: toSearchInstruction
                    )
                    
                    Divider()

                    HelpInstructionView(
                        symbol: "star.fill",
                        color: .red,
                        text: favoritesInstruction
                    )
                }
                .padding(.horizontal, .spacing(.medium))
                .padding(.vertical, .spacing(.xSmall))
            }
        }
        .navigationTitle("Ajuda")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Text

extension HelpView {

    private var toPlayInstruction: String {
        if UIDevice.isMac {
            return "Para reproduzir um conteúdo, clique nele 1 vez. Para parar de reproduzir, clique nele novamente."
        } else {
            return "Para reproduzir um conteúdo, toque nele 1 vez. Para parar de reproduzir, toque nele novamente."
        }
    }

    private var toShareInstruction: String {
        if UIDevice.isMac {
            return "Para compartilhar, clique com o botão direito no conteúdo e escolha Compartilhar."
        } else {
            return "Para compartilhar, segure o conteúdo por alguns segundos até que o menu de contexto abra e escolha Compartilhar."
        }
    }

    private var toSearchInstruction: String {
        if UIDevice.isMac {
            return "Para pesquisar, clique no campo Buscar no canto superior direito da tela de sons e digite o texto que procura.\n\nA pesquisa considera o que é falado no áudio e o nome do autor ou gênero musical. Não use vírgulas."
        } else {
            if UIDevice.isiPhone {
                return "Para pesquisar, vá até o topo da lista de conteúdos e puxe mais um pouco para baixo até revelar o campo Buscar.\n\nA pesquisa considera o que é falado no áudio e o nome do autor ou gênero musical. Não use vírgulas."
            } else {
                return "Para pesquisar, toque no campo Buscar no canto superior direito da tela de sons e digite o texto que procura.\n\nA pesquisa considera o que é falado no áudio e o nome do autor ou gênero musical. Não use vírgulas."
            }
        }
    }

    private var favoritesInstruction: String {
        if UIDevice.isMac {
            return "Para favoritar, clique com o botão direito em um conteúdo e escolha Adicionar aos Favoritos.\n\nPara ver apenas os favoritos, clique em Favoritos na barra lateral.\n\nÉ possível pesquisar entre os favoritos usando o campo Buscar no topo direito da tela de Favoritos."
        } else {
            if UIDevice.isiPhone {
                return "Para favoritar, segure o conteúdo e escolha Adicionar aos Favoritos.\n\nPara ver apenas os favoritos, toque em Favoritos nos filtros da parte superior da tela.\n\nÉ possível pesquisar entre os favoritos usando a barra de Busca. Para isso, na lista de favoritos, vá até o topo e puxe mais um pouco para baixo até ver a barra."
            } else {
                return "Para favoritar, segure o conteúdo e escolha Adicionar aos Favoritos.\n\nPara ver apenas os favoritos, toque em Favoritos na barra lateral.\n\nÉ possível pesquisar entre os favoritos usando o campo Buscar no topo direito da tela de Favoritos."
            }
        }
    }
}

// MARK: - Subviews

extension HelpView {

    struct HelpInstructionView: View {

        let symbol: String
        var color: Color = .accentColor
        let iconFrameWidth: CGFloat = 40
        let text: String

        var body: some View {
            HStack {
                Image(systemName: symbol)
                    .font(.largeTitle)
                    .foregroundColor(color)
                    .frame(width: iconFrameWidth)
                    .padding(.leading, .spacing(.xxxSmall))
                    .padding(.trailing, .spacing(.xSmall))

                Text(text)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        HelpView()
    }
}
