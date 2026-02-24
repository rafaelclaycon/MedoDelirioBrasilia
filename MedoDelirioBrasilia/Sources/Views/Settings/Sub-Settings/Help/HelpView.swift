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

                    Divider()
                        .padding(.vertical, .spacing(.small))

                    Text("Episódios")
                        .font(.title)
                        .bold()

                    HelpInstructionView(
                        symbol: "play.circle.fill",
                        color: .green,
                        text: episodePlayInstruction
                    )

                    Divider()

                    HelpInstructionView(
                        symbol: "hand.draw",
                        text: episodeSwipeInstruction
                    )

                    Divider()

                    HelpInstructionView(
                        symbol: "goforward.30",
                        color: .green,
                        text: episodeControlsInstruction
                    )

                    Divider()

                    HelpInstructionView(
                        symbol: "bookmark.fill",
                        color: .red,
                        text: episodeBookmarkInstruction
                    )

                    Divider()

                    HelpInstructionView(
                        symbol: "arrow.down.circle",
                        color: .green,
                        text: episodeDownloadInstruction
                    )

                    Divider()

                    HelpInstructionView(
                        symbol: "line.3.horizontal.decrease",
                        text: episodeFilterInstruction
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
    // MARK: - Episodes

    private var episodePlayInstruction: String {
        "Toque em um episódio para ver os detalhes. Toque no botão de Play ao lado de cada episódio para reproduzir. Uma barra aparece na parte inferior, toque nela para abrir a tela Reproduzindo Agora com a capa, o progresso e os controles."
    }

    private var episodeControlsInstruction: String {
        "Na tela Reproduzindo Agora, arraste a barra de progresso para pular para qualquer ponto. Use os botões para voltar 15 segundos ou avançar 30 segundos. O progresso é salvo automaticamente. Se você sair e voltar, a reprodução continua de onde parou."
    }

    private var episodeBookmarkInstruction: String {
        "Enquanto ouve, toque em \"Marcar Esse Ponto\" para salvar o momento atual. Os marcadores aparecem como linhas vermelhas na barra de progresso e em uma lista abaixo.\n\nToque no Play ao lado de qualquer marcador para pular até aquele ponto novamente. Você também pode dar um nome, adicionar uma nota e excluir marcadores tocando em um deles."
    }

    private var episodeDownloadInstruction: String {
        "Todo episódio selecionado para reprodução é primeiro baixado offline antes de reproduzir. Uma vez baixado, ele toca sem internet.\n\nPara apagar o download, abra os detalhes do episódio, toque na lixeira ao lado do tamanho do arquivo e confirme."
    }

    private var episodeFilterInstruction: String {
        "A lista de episódios tem filtros horizontais e de menu que podem ser combinados. Na parte superior: Todos, Favoritos e Com Marcadores.\n\nNo menu do canto direito você pode filtrar por estado de reprodução (Não Iniciado, Em Progresso, Finalizado). Use o menu de ordenação para ver os mais recentes ou mais antigos primeiro."
    }

    private var episodeSwipeInstruction: String {
        "Deslize um episódio para a direita para favoritar ou desfavoritar. Deslize para a esquerda para marcar como finalizado ou desfazer."
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
