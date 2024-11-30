//
//  ReactionDetailHeader.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 02/05/24.
//

import SwiftUI
import Kingfisher

struct ReactionDetailHeader: View {

    let title: String
    let subtitle: String
    let imageUrl: String
    let attributionText: String?
    let attributionURL: URL?

    @ScaledMetric(relativeTo: .caption) private var attURLSymbolWidth: CGFloat = 12

    var body: some View {
        VStack(alignment: .leading) {
            Spacer()

            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(.white)
                        .shadow(color: .black, radius: 4, x: 2, y: 2)

                    Text(subtitle)
                        .foregroundStyle(.white)
                        .shadow(color: .black, radius: 6, x: 1, y: 2)

                    if let attributionText, let attributionURL {
                        Button {
                            OpenUtility.open(attributionURL)
                        } label: {
                            HStack(spacing: .spacing(.xSmall)) {
                                Text("📸  " + attributionText)
                                    .font(.caption)
                                    .bold()

                                Image(systemName: "rectangle.portrait.and.arrow.forward")
                                    .resizable()
                                    .scaledToFit()
                                    .bold()
                                    .frame(width: attURLSymbolWidth)
                            }
                            .foregroundStyle(.white)
                            .shadow(color: .black, radius: 6, x: 1, y: 2)

                        }
                        .padding(.top, .spacing(.small))
                    }
                }

                Spacer()
            }
            .padding([.top,.leading,.trailing], 22)
            .padding(.bottom, attributionText != nil ? 12 : 22)
        }
        .background {
            KFImage(URL(string: imageUrl))
                .placeholder {
                    Image(systemName: "photo.on.rectangle")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .foregroundColor(.gray)
                        .opacity(0.3)
                }
                .resizable()
                .scaledToFill()
                .overlay(Color.black.opacity(0.3))
                .blur(radius: 1)
                .scaleEffect(1.05)
                .frame(height: 260)
                //.frame(width: headerPhotoGeometry.size.width, height: self.getHeightForHeaderImage(headerPhotoGeometry))
                .clipped()
        }
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }
}

#Preview {
    VStack {
        ReactionDetailHeader(
            title: Reaction.acidMock.title,
            subtitle: "28 sons. Atualizada há 14 horas.",
            imageUrl: Reaction.acidMock.image,
            attributionText: "GABRIELA BILÓ EM INSTAGRAM.",
            attributionURL: URL(string: "https://www.instagram.com/gabriela.bilo")!
        )
        .frame(height: 260)

        Spacer()
    }
    .ignoresSafeArea()
}
