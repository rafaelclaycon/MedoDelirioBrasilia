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
                             creationDate: .empty))
        array.append(Episode(episodeId: "https://www.central3.com.br/?p=46083",
                             title: "Dias 1.441, 1.442 e 1.443 | O mais patético dos pedidos de ajuda | 09, 10 e 11/12/22",
                             description: "Foi o Constantino; Medo e Delírio em Brasília; A diplomação; Menina Rosa.",
                             pubDate: "2022-12-15T05:47:52.000Z",
                             duration: 2530,
                             creationDate: .empty))
        array.append(Episode(episodeId: "https://www.central3.com.br/?p=46063",
                             title: "Dias 1.439 e 1.440 | Conciliações | 07 e 08/12/22",
                             description: "Foi o Constantino; Medo e Delírio em Brasília; A diplomação; Menina Rosa.",
                             pubDate: "2022-12-15T05:47:52.000Z",
                             duration: 1831,
                             creationDate: .empty))
        array.append(Episode(episodeId: "https://www.central3.com.br/?p=46042",
                             title: "Dias 1.437 e 1.438 | Terra arrasada | 05 e 06/12/22",
                             description: "Foi o Constantino; Medo e Delírio em Brasília; A diplomação; Menina Rosa.",
                             pubDate: "2022-12-15T05:47:52.000Z",
                             duration: 2382,
                             creationDate: .empty))
        array.append(Episode(episodeId: "https://www.central3.com.br/?p=46034",
                             title: "Dias 1.432 a 1.436 | “Não tem como não dar errado, vai dar errado” | 30/11 a 4/12/22",
                             description: "Foi o Constantino; Medo e Delírio em Brasília; A diplomação; Menina Rosa.",
                             pubDate: "2022-12-15T05:47:52.000Z",
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
