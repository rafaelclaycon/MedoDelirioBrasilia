//
//  AlbumCoverPlayView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Schmitt on 07/09/23.
//

import SwiftUI

struct AlbumCoverPlayView: View {

    @Binding var isPlaying: Bool

    private let regularGradient = LinearGradient(gradient: Gradient(colors: [.green, .green, .brightYellow]), startPoint: .topTrailing, endPoint: .bottomLeading)

    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(regularGradient)
            .frame(width: 200, height: 200)
            .blur(radius: 2)
            .overlay {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60)
                    .foregroundColor(.white)
            }
    }
}

struct AlbumCoverPlayView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumCoverPlayView(isPlaying: .constant(false))
    }
}
