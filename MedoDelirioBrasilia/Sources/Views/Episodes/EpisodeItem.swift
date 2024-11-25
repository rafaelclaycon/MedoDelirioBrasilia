//
//  EpisodeItem.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 26/10/22.
//

import SwiftUI

struct EpisodeItem: View {

    let episode: Episode

    private var dateAndDuration: String {
        (episode.pubDate.iso8601withFractionalSeconds?.asShortString() ?? .empty)  + " · " + episode.duration.toDisplayString()
    }

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text(episode.title)
                        .font(.headline)
                    
                    Text(episode.description)
                        .foregroundColor(.gray)
                        .font(.subheadline)
                        .lineLimit(2)
                    
                    Text(dateAndDuration)
                        .bold()
                        .font(.footnote)
                }
                .padding(.leading, 10)
                
                Spacer()
            }
            
            HStack(spacing: 20) {
                Button {
                    //Opener.open(link: episode.spotifyLink)
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
                    //Opener.open(link: episode.applePodcastsLink)
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
                    //Opener.open(link: episode.pocketCastsLink)
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

// MARK: Preview

#Preview {
    EpisodeItem(
        episode: Episode(
            episodeId: "123",
            title: "Dias 1.390, 1.391 e 1.392 | Bob e Jeff em Comendador Levy Gasparian | Dias 21, 22 e 23/10/22",
            description: "Bob Jeff in the sky with grenades.",
            pubDate: "2022-12-15T05:47:52.000Z",
            duration: 300,
            creationDate: .empty
        )
    )
}
