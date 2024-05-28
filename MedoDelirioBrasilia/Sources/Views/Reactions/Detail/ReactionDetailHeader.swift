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
                }

                Spacer()
            }
            .padding(.all, 22)
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
                .frame(height: 250)
                //.frame(width: headerPhotoGeometry.size.width, height: self.getHeightForHeaderImage(headerPhotoGeometry))
                .clipped()
        }
    }
}

#Preview {
    VStack {
        ReactionDetailHeader(
            title: "entusiasmo",
            subtitle: "28 sons. Atualizada há 14 horas.",
            imageUrl: "https://images.unsplash.com/photo-1489710437720-ebb67ec84dd2?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
        )
        .frame(height: 250)

        Spacer()
    }
    .ignoresSafeArea()
}
