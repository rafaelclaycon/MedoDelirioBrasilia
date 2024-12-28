//
//  WPStartView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 25/12/24.
//

import SwiftUI

struct WPStartView: View {

    var body: some View {
        ScrollView {
            VStack {
                HStack(spacing: 12) {
                    Tile(
                        symbol: "speaker.wave.3.fill",
                        text: "Sons"
                    )

                    Tile(
                        symbol: "music.quarternote.3",
                        text: "Músicas"
                    )
                }

                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 30)
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()

                Image(systemName: "arrow.left")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20)
                    .foregroundStyle(.white)

                Spacer()

                Image("logo_wp_theme")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44)
                    .padding(.horizontal)

                Spacer()

                Image(systemName: "magnifyingglass")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20)
                    .foregroundStyle(.white)

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background {
                Color.black
            }
        }
    }
}

#Preview {
    WPStartView()
}
