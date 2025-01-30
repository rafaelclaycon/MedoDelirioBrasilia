//
//  WPSoundItem.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 28/12/24.
//

import SwiftUI

struct WPSoundItem: View {

    let sound: Sound

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(sound.title)
                .font(.title)
                .fontWeight(.light)
                .lineLimit(1)

            Text(sound.authorName ?? "")
                .foregroundStyle(.gray)
                .lineLimit(1)
        }
    }
}

#Preview {
    WPSoundItem(
        sound: Sound(
            title: "Tu quer o cu e ainda quer raspado",
            authorName: "Samanta Alves"
        )
    )
}
