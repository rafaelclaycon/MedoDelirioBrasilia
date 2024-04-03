//
//  ExternalLinkButton.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 26/03/24.
//

import SwiftUI
import Kingfisher

struct ExternalLinkButton: View {

    let externalLink: ExternalLink

    var imageUrl: URL {
        URL(string: "\(baseURL)images/\(externalLink.symbol)")!
    }

    var body: some View {
        Button {
            OpenUtility.open(link: externalLink.link)
        } label: {
            HStack(spacing: 10) {
                KFImage(imageUrl)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22)

                Text(externalLink.title)
            }
            .padding(.vertical, 2)
            .padding(.horizontal, 6)
        }
        .capsule(colored: externalLink.color.toColor())
    }
}

#Preview {
    ExternalLinkButton(
        externalLink: .init(
            symbol: "youtube-full-color.png",
            title: "YouTube",
            color: "red",
            link: "https://www.youtube.com/@CasimiroMiguel"
        )
    )
}
