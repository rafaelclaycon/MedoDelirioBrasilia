//
//  EpisodeView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 25/10/22.
//

import SwiftUI

struct EpisodeView: View {

    var body: some View {
        List(getLocalEpisodes()) { episode in
            EpisodeCell(viewModel: EpisodeCellViewModel(episode: episode))
        }
        .navigationTitle("Episódios")
        
//        ScrollView {
//            VStack {
//                
//            }
//            .navigationTitle("Episódios")
//        }
    }
    
    private func getLocalEpisodes() -> [Episode] {
        var array = [Episode]()
        array.append(Episode(episodeId: "https://www.central3.com.br/?p=46090",
                             title: "Dias 1.444 e 1.445 | Medo e delírio em Brasília | 12 e 13/12/22",
                             description: "Foi o Constantino; Medo e Delírio em Brasília; A diplomação; Menina Rosa.",
                             pubDate: "2022-12-15T05:47:52.000Z",
                             duration: 2625,
                             creationDate: .empty,
                             spotifyLink: "https://open.spotify.com/episode/4hhbmWYNHGjoC0TFmMA9ND?si=bbf7rd8cRX6Smhwc7Vusmw",
                             applePodcastsLink: "https://podcasts.apple.com/br/podcast/medo-e-del%C3%ADrio-em-bras%C3%ADlia/id1502134265?i=1000590240317",
                             pocketCastsLink: "https://pca.st/episode/c7252e37-6d22-43ea-ad87-d2302b3bc3c5"))
        array.append(Episode(episodeId: "https://www.central3.com.br/?p=46083",
                             title: "Dias 1.441, 1.442 e 1.443 | O mais patético dos pedidos de ajuda | 09, 10 e 11/12/22",
                             description: "Lula diplomado; O Mito pede ajuda; Zé Múcio; Anistia é o caralho.",
                             pubDate: "2022-12-13T17:52:14.000Z",
                             duration: 2530,
                             creationDate: .empty,
                             spotifyLink: "https://open.spotify.com/show/4GTrddwqYaFDOuNUPcsRaX?si=32cf2e5496d3494c",
                             applePodcastsLink: "https://podcasts.apple.com/br/podcast/medo-e-del%C3%ADrio-em-bras%C3%ADlia/id1502134265",
                             pocketCastsLink: "https://pca.st/podcast/888d5760-4c1b-0138-9785-0acc26574db2"))
        array.append(Episode(episodeId: "https://www.central3.com.br/?p=46063",
                             title: "Dias 1.439 e 1.440 | Conciliações | 07 e 08/12/22",
                             description: "Brasil perdeu; Julgamento do orçamento secreto; Lula e os militares; A resistência do Itamaraty; Heleno petulante; Bolsonaro quebra o silêncio.",
                             pubDate: "2022-12-10T03:24:59.000Z",
                             duration: 1831,
                             creationDate: .empty))
        array.append(Episode(episodeId: "https://www.central3.com.br/?p=46042",
                             title: "Dias 1.437 e 1.438 | Terra arrasada | 05 e 06/12/22",
                             description: "Calamidade, desmonte, descaso, irresponsabilidade, má-fé.",
                             pubDate: "2022-12-08T04:32:26.000Z",
                             duration: 2382,
                             creationDate: .empty))
        array.append(Episode(episodeId: "https://www.central3.com.br/?p=46034",
                             title: "Dias 1.432 a 1.436 | “Não tem como não dar errado, vai dar errado” | 30/11 a 4/12/22",
                             description: "Militares e o governo Lula.",
                             pubDate: "2022-12-06T03:04:52.000Z",
                             duration: 1618,
                             creationDate: .empty))
        return array
    }

}

struct EpisodeView_Previews: PreviewProvider {

    static var previews: some View {
        EpisodeView()
    }

}
