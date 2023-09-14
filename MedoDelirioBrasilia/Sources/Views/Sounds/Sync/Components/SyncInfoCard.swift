//
//  SyncInfoCard.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 21/08/23.
//

import SwiftUI

struct SyncInfoCard: View {

    let imageName: String
    let imageColor: Color
    let title: String
    let timestamp: String

    var body: some View {
        HStack(spacing: .zero) {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 30)
                .foregroundColor(imageColor)
                .padding(.leading, 5)

            Spacer()
                .frame(width: 14)

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.callout)
                    .multilineTextAlignment(.leading)

                Text(timestamp)
                    .foregroundColor(.gray)
                    .font(.footnote)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .padding(.horizontal, 5)
        .background(.background)
        .cornerRadius(13)
        .shadow(radius: 4, y: 3)
    }
}

struct SyncInfoCard_Previews: PreviewProvider {

    static var previews: some View {
        SyncInfoCard(
            imageName: "exclamationmark.triangle",
            imageColor: .orange,
            title: "Não foi possível conectar ao servidor.",
            timestamp: "21/08/2023 18:52"
        )
        .padding()
    }
}
