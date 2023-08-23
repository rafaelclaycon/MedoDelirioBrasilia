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
    //let text: String
    let timestamp: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 30)
                .foregroundColor(imageColor)

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .multilineTextAlignment(.leading)

                Text(timestamp)
                    .foregroundColor(.gray)
                    .font(.callout)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .padding(.horizontal, 5)
        .background(.background)
        .cornerRadius(13)
        .shadow(radius: 4, y: 3)
    }
}

struct SyncInfoCard_Previews: PreviewProvider {

    static var previews: some View {
        SyncInfoCard(
            imageName: "exclamationmark.triangle.fill",
            imageColor: .gray,
            title: "Não foi possível conectar ao servidor.",
            timestamp: "21/08/2023 18:52"
        )
        .padding()
    }
}
