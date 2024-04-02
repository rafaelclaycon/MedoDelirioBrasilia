//
//  ExternalLinkButton.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 26/03/24.
//

import SwiftUI
import Kingfisher

struct ExternalLinkButton: View {

    let title: String
    let color: Color
    let symbol: String
    let link: String

    var imageUrl: URL {
        URL(string: "\(baseURL)images/\(symbol)")!
    }

    var body: some View {
        Button {
            OpenUtility.open(link: link)
        } label: {
            HStack(spacing: 10) {
                KFImage(imageUrl)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22)

                Text(title)
            }
            .padding(.vertical, 2)
            .padding(.horizontal, 6)
        }
        .capsule(colored: color)
    }
}

#Preview {
    ExternalLinkButton(
        title: "YouTube",
        color: .red,
        symbol: "youtube-full-color.png",
        link: "https://www.youtube.com/@CasimiroMiguel"
    )
}
