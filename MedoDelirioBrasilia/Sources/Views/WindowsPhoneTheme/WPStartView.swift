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
            }
            .padding(.horizontal)
            .padding(.vertical, 30)
        }
    }
}

#Preview {
    WPStartView()
}
