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
            return "Para pesquisar por conteúdos, selecione Buscar na barra lateral.\n\nA pesquisa destaca tanto resultados encontrados no título ou autor quanto dentro do áudio."
        } else {
            if UIDevice.isiPhone {
                if UIDevice.isIOS26OrLater {
                    return "Para pesquisar, toque na lupa no canto inferior direito da tela a qualquer momento.\n\nA pesquisa destaca tanto resultados encontrados no título ou autor do conteúdo quanto dentro do áudio."
                } else {
                    return "Para pesquisar, vá até o topo da lista de conteúdos e puxe mais um pouco para baixo até revelar o campo Buscar.\n\nA pesquisa considera o que é falado no áudio e o nome do autor ou gênero musical. Não use vírgulas."
                }
            } else {
                // iPad - sidebar search available in iOS 18+
                return "Para pesquisar por conteúdos, toque em Buscar na barra lateral.\n\nA pesquisa destaca tanto resultados encontrados no título ou autor quanto dentro do áudio."
            }
        }
    }

    private var favoritesInstruction: String {
        if UIDevice.isMac {
            return "Para favoritar, clique com o botão direito em um conteúdo e escolha Adicionar aos Favoritos.\n\nPara ver apenas os favoritos, clique em Favoritos na barra lateral."
        } else {
            if UIDevice.isiPhone {
                return "Para favoritar, segure o conteúdo e escolha Adicionar aos Favoritos.\n\nPara ver apenas os favoritos, toque em Favoritos nos filtros da parte superior da tela."
            } else {
                return "Para favoritar, segure o conteúdo e escolha Adicionar aos Favoritos.\n\nPara ver apenas os favoritos, toque em Favoritos na barra lateral."
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
