//
//  EpisodeCell.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 26/10/22.
//

import SwiftUI

struct EpisodeCell: View {

    @StateObject var viewModel: EpisodeCellViewModel
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text(viewModel.title)
                        .font(.headline)
                    
                    Text(viewModel.description)
                        .foregroundColor(.gray)
                        .font(.subheadline)
                        .lineLimit(2)
                    
                    Text(viewModel.subtitle)
                        .bold()
                        .font(.footnote)
                }
                .padding(.leading, 10)
                
                Spacer()
            }
            
            HStack(spacing: 20) {
                Button {
                    Opener.open(link: viewModel.spotifyLink)
                } label: {
                    Image("spotify")
                        .renderingMode(.template)
                        .foregroundColor(.green)
                        .padding(.horizontal)
                }
                .tint(.green)
                .controlSize(.regular)
                .buttonStyle(.bordered)
                .buttonBorderShape(.roundedRectangle)
                
                Button {
                    Opener.open(link: viewModel.applePodcastsLink)
                } label: {
                    Image("apple_podcasts")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.purple)
                        .frame(width: 24, height: 24)
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                }
                .tint(.purple)
                .controlSize(.regular)
                .buttonStyle(.bordered)
                .buttonBorderShape(.roundedRectangle)
                
                Button {
                    Opener.open(link: viewModel.pocketCastsLink)
                } label: {
                    Image("pocket_casts")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.red)
                        .frame(width: 24, height: 24)
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                }
                .tint(.red)
                .controlSize(.regular)
                .buttonStyle(.bordered)
                .buttonBorderShape(.roundedRectangle)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 2)
        }
    }

}

struct EpisodeCell_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            EpisodeCell(viewModel: EpisodeCellViewModel(episode: Episode(episodeId: "123",
                                                                         title: "Dias 1.390, 1.391 e 1.392 | Bob e Jeff em Comendador Levy Gasparian | Dias 21, 22 e 23/10/22",
                                                                         description: "Bob Jeff in the sky with grenades.",
                                                                         pubDate: "2022-12-15T05:47:52.000Z",
                                                                         duration: 300,
                                                                         creationDate: .empty)))
            
            EpisodeCell(viewModel: EpisodeCellViewModel(episode: Episode(episodeId: "456",
                                                                         title: "Dias 1.386 a 1.389 | A indiscrição que comove | 17 a 20/10/22",
                                                                         description: "Conrado Hubner Mendes e o Curriculum Vitae de Bolsonaro, um dossiê; Dê de presente nosso futuro livro em www.averdadevoslibertara.com.br; Militares e eleições; Bolsonaro, mais ministros no STF; Guedes e o salário mínimo.",
                                                                         pubDate: "2022-12-15T05:47:52.000Z",
                                                                         duration: 3600,
                                                                         creationDate: .empty)))
        }
        .previewLayout(.fixed(width: 350, height: 100))
    }

}
