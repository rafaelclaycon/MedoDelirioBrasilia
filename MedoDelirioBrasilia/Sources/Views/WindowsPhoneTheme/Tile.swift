//
//  Tile.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 25/12/24.
//

import SwiftUI

struct Tile: View {

    let symbol: String
    let text: String

    var body: some View {
        Rectangle()
            .fill(.blue)
            .frame(width: 160, height: 150)
            .overlay {
                Image(systemName: symbol)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60)
            }
            .overlay(alignment: .bottomLeading) {
                Text(text)
                    .bold()
                    .padding(.all, 9)
            }
    }
}

#Preview {
    Tile(
        symbol: "speaker.wave.3.fill",
        text: "Sons"
    )
    .foregroundStyle(.white)
    .background {
        Color.black
    }
}
