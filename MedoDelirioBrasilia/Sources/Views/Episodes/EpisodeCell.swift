//
//  EpisodeCell.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 26/10/22.
//

import SwiftUI

struct EpisodeCell: View {

    @StateObject var viewModel: EpisodeCellViewModel
    
    // MARK: - Checkmark component
    private let circleSize: CGFloat = 32.0
    private let unselectedFillColor: Color = .white
    private let unselectedForegroundColor: Color = .gray
    private let selectedFillColor: Color = .pink

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 7) {
                    Text(viewModel.title)
                        .lineLimit(2)
                    
                    Text(viewModel.subtitle)
                        .foregroundColor(.gray)
                        .bold()
                        .font(.footnote)
                }
                .padding(.leading, 10)
                
                Spacer()
            }
            
            HStack(spacing: 20) {
                Button {
                    print("Spotify")
                } label: {
                    HStack {
                        Image(systemName: "airpodsmax")
                        Text("Spotify")
                    }
                }
                Button {
                    print("Podcasts")
                } label: {
                    HStack {
                        Image(systemName: "airpodsmax")
                        Text("Podcasts")
                    }
                }
                .foregroundColor(.purple)
                Button {
                    print("Pocket Casts")
                } label: {
                    HStack {
                        Image(systemName: "airpodsmax")
                        Text("Pocket Casts")
                    }
                }
                .foregroundColor(.red)
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
            EpisodeCell(viewModel: EpisodeCellViewModel(episode: Episode(id: "1",
                                                                       podcastId: 123,
                                                                       title: "Dias 1.390, 1.391 e 1.392 | Bob e Jeff em Comendador Levy Gasparian | Dias 21, 22 e 23/10/22",
                                                                       pubDate: Date(),
                                                                       duration: 300,
                                                                       originalRemoteUrl: .empty)))
            
            EpisodeCell(viewModel: EpisodeCellViewModel(episode: Episode(id: "2",
                                                                         podcastId: 456,
                                                                         title: "Dias 1.386 a 1.389 | A indiscrição que comove | 17 a 20/10/22",
                                                                         pubDate: Date(),
                                                                         duration: 3600,
                                                                         originalRemoteUrl: .empty)))
        }
        .previewLayout(.fixed(width: 350, height: 100))
    }
    
}
