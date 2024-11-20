//
//  MixSoundsView.swift
//  MedoDelirioBrasilia
//
//  Created by Rafael Claycon Schmitt on 04/02/23.
//

import SwiftUI

struct MixSoundsView: View {

    let sounds: [Sound]

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 80) {
                    if sounds.count == 0 {
                        WhatIsSoundMixView()
                    } else {
                        LazyVStack {
                            ForEach(sounds.indices, id: \.self) { i in
                                MixSoundItem(
                                    mixSound: MixSound(position: i + 1, sound: sounds[i])
                                )
                            }
                        }
                        .padding(.all)
                    }

                    Button {
                        print("Play")
                    } label: {
                        Image(systemName: "play.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 30)
                            .foregroundColor(.primary)
                    }

                    Button {
                        print("Share")
                    } label: {
                        HStack(spacing: 25) {
                            Image(systemName: "square.and.arrow.up")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 25)

                            Text("Compartilhar")
                                .font(.headline)
                        }
                        .padding(.horizontal, 25)
                    }
                    .tint(.accentColor)
                    .controlSize(.large)
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                }
                .navigationTitle("Misturar Sons")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(leading:
                    Button("Fechar") {
                        dismiss()
                    }
                )
            }
        }
    }
}

// MARK: - Subviews

extension MixSoundsView {

    struct WhatIsSoundMixView: View {

        var body: some View {
            VStack(alignment: .center, spacing: 30) {
                Text("Bem-vinde à Mistura de Sons")
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)

                Text("Segure em vários sons nas lista principal e escolha Adicionar à Mistura. Depois volte aqui e reordene os sons do jeito que quiser. Compartilhe o resultado dessa mistura!")
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 30)
            .padding(.vertical)
        }
    }
}

// MARK: - Preview

#Preview {
    MixSoundsView(sounds: [])
}
