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
                .padding(.leading, 8)

            Spacer()
                .frame(width: .spacing(.medium))

            VStack(alignment: .leading, spacing: .spacing(.xSmall)) {
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
    }
}

#Preview {
    SyncInfoCard(
        imageName: "exclamationmark.triangle",
        imageColor: .orange,
        title: "Não foi possível conectar ao servidor.",
        timestamp: "21/08/2023 18:52"
    )
    .padding()
}
